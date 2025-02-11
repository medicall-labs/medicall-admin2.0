const String tableContact = 'tbl_contact';
const String tblContactColId = 'id';
const String tblContactColName = 'name';
const String tblContactColMobile = 'mobile';
const String tblContactColEmail = 'email';
const String tblContactColAddress = 'address';
const String tblContactColCompany = 'company';
const String tblContactColDesignation = 'designation';
const String tblContactColWebsite = 'website';
const String tblContactColImage = 'image';
const String tblContactColFavorite = 'favorite';
const String tblContactBusinessType = 'business_type';

class ContactModel {
  int id;
  String name;
  String mobile;
  String email;
  String address;
  String company;
  String designation;
  String website;
  String image;
  String business_type;
  bool favorite;

  ContactModel({
    this.id = -1,
    required this.name,
    required this.mobile,
    this.email = '',
    this.address = '',
    this.company = '',
    this.designation = '',
    this.website = '',
    this.image = '',
    this.business_type = '',
    this.favorite = false,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      tblContactColName: name,
      tblContactColMobile: mobile,
      tblContactColEmail: email,
      tblContactColAddress: address,
      tblContactColCompany: company,
      tblContactColDesignation: designation,
      tblContactColWebsite: website,
      tblContactColImage: image,
      tblContactBusinessType: business_type,
      tblContactColFavorite: favorite ? 1 : 0,
    };
    if (id > 0) {
      map[tblContactColId] = id;
    }
    return map;
  }

  factory ContactModel.fromMap(Map<String, dynamic> map) => ContactModel(
        name: map[tblContactColName],
        mobile: map[tblContactColMobile],
        email: map[tblContactColEmail],
        address: map[tblContactColAddress],
        company: map[tblContactColCompany],
        designation: map[tblContactColDesignation],
        website: map[tblContactColWebsite],
        image: map[tblContactColImage],
        business_type: map[tblContactBusinessType],
        favorite: map[tblContactColFavorite] == 1 ? true : false,
      );

  @override
  String toString() {
    return 'ContactModel{id: $id, name: $name, mobile: $mobile, email: $email, address: $address, company: $company, designation: $designation, website: $website, image: $image, business_type: $business_type , favorite: $favorite}';
  }
}
