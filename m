Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id 56C816B0005
	for <linux-mm@kvack.org>; Wed, 30 Mar 2016 00:21:13 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id zm5so30320109pac.0
        for <linux-mm@kvack.org>; Tue, 29 Mar 2016 21:21:13 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id et14si3442540pac.19.2016.03.29.21.21.11
        for <linux-mm@kvack.org>;
        Tue, 29 Mar 2016 21:21:12 -0700 (PDT)
Date: Wed, 30 Mar 2016 12:19:44 +0800
From: kbuild test robot <lkp@intel.com>
Subject: Re: [PATCH v2 1/5] block, dax: pass blk_dax_ctl through to drivers
Message-ID: <201603301229.Pj7DWz3a%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="ew6BAiZeqk4r7MaW"
Content-Disposition: inline
In-Reply-To: <1459303190-20072-2-git-send-email-vishal.l.verma@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vishal Verma <vishal.l.verma@intel.com>
Cc: kbuild-all@01.org, linux-nvdimm@lists.01.org, Dan Williams <dan.j.williams@intel.com>, linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org, xfs@oss.sgi.com, linux-ext4@vger.kernel.org, linux-mm@kvack.org, Matthew Wilcox <matthew.r.wilcox@intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Jens Axboe <axboe@fb.com>, Al Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>


--ew6BAiZeqk4r7MaW
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dan,

[auto build test ERROR on linux-nvdimm/libnvdimm-for-next]
[also build test ERROR on v4.6-rc1 next-20160329]
[cannot apply to xfs/for-next]
[if your patch is applied to the wrong git tree, please drop us a note to help improving the system]

url:    https://github.com/0day-ci/linux/commits/Vishal-Verma/dax-handling-of-media-errors/20160330-100409
base:   https://git.kernel.org/pub/scm/linux/kernel/git/nvdimm/nvdimm libnvdimm-for-next
config: s390-default_defconfig (attached as .config)
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=s390 

All error/warnings (new ones prefixed by >>):

   drivers/s390/block/dcssblk.c: In function 'dcssblk_direct_access':
>> drivers/s390/block/dcssblk.c:36:13: error: storage class specified for parameter 'dcssblk_segments'
    static char dcssblk_segments[DCSSBLK_PARM_LEN] = "\0";
                ^
>> drivers/s390/block/dcssblk.c:36:1: error: parameter 'dcssblk_segments' is initialized
    static char dcssblk_segments[DCSSBLK_PARM_LEN] = "\0";
    ^
>> drivers/s390/block/dcssblk.c:38:12: error: storage class specified for parameter 'dcssblk_major'
    static int dcssblk_major;
               ^
>> drivers/s390/block/dcssblk.c:39:45: error: storage class specified for parameter 'dcssblk_devops'
    static const struct block_device_operations dcssblk_devops = {
                                                ^
>> drivers/s390/block/dcssblk.c:39:21: error: parameter 'dcssblk_devops' is initialized
    static const struct block_device_operations dcssblk_devops = {
                        ^
>> drivers/s390/block/dcssblk.c:46:1: warning: empty declaration
    struct dcssblk_dev_info {
    ^
   drivers/s390/block/dcssblk.c:62:1: warning: empty declaration
    struct segment_info {
    ^
>> drivers/s390/block/dcssblk.c:70:16: error: storage class specified for parameter 'dcssblk_add_store'
    static ssize_t dcssblk_add_store(struct device * dev, struct device_attribute *attr, const char * buf,
                   ^
>> drivers/s390/block/dcssblk.c:72:16: error: storage class specified for parameter 'dcssblk_remove_store'
    static ssize_t dcssblk_remove_store(struct device * dev, struct device_attribute *attr, const char * buf,
                   ^
   In file included from include/linux/genhd.h:63:0,
                    from include/linux/blkdev.h:9,
                    from drivers/s390/block/dcssblk.c:16:
>> include/linux/device.h:575:26: error: storage class specified for parameter 'dev_attr_add'
     struct device_attribute dev_attr_##_name = __ATTR(_name, _mode, _show, _store)
                             ^
>> drivers/s390/block/dcssblk.c:75:8: note: in expansion of macro 'DEVICE_ATTR'
    static DEVICE_ATTR(add, S_IWUSR, NULL, dcssblk_add_store);
           ^
>> include/linux/device.h:575:9: error: parameter 'dev_attr_add' is initialized
     struct device_attribute dev_attr_##_name = __ATTR(_name, _mode, _show, _store)
            ^
>> drivers/s390/block/dcssblk.c:75:8: note: in expansion of macro 'DEVICE_ATTR'
    static DEVICE_ATTR(add, S_IWUSR, NULL, dcssblk_add_store);
           ^
>> include/linux/device.h:575:26: error: storage class specified for parameter 'dev_attr_remove'
     struct device_attribute dev_attr_##_name = __ATTR(_name, _mode, _show, _store)
                             ^
   drivers/s390/block/dcssblk.c:76:8: note: in expansion of macro 'DEVICE_ATTR'
    static DEVICE_ATTR(remove, S_IWUSR, NULL, dcssblk_remove_store);
           ^
>> include/linux/device.h:575:9: error: parameter 'dev_attr_remove' is initialized
     struct device_attribute dev_attr_##_name = __ATTR(_name, _mode, _show, _store)
            ^
   drivers/s390/block/dcssblk.c:76:8: note: in expansion of macro 'DEVICE_ATTR'
    static DEVICE_ATTR(remove, S_IWUSR, NULL, dcssblk_remove_store);
           ^
>> drivers/s390/block/dcssblk.c:78:23: error: storage class specified for parameter 'dcssblk_root_dev'
    static struct device *dcssblk_root_dev;
                          ^
   In file included from include/linux/module.h:9:0,
                    from drivers/s390/block/dcssblk.c:10:
>> drivers/s390/block/dcssblk.c:80:18: error: storage class specified for parameter 'dcssblk_devices'
    static LIST_HEAD(dcssblk_devices);
                     ^
   include/linux/list.h:23:19: note: in definition of macro 'LIST_HEAD'
     struct list_head name = LIST_HEAD_INIT(name)
                      ^
>> include/linux/list.h:23:9: error: parameter 'dcssblk_devices' is initialized
     struct list_head name = LIST_HEAD_INIT(name)
            ^
>> drivers/s390/block/dcssblk.c:80:8: note: in expansion of macro 'LIST_HEAD'
    static LIST_HEAD(dcssblk_devices);
           ^
>> drivers/s390/block/dcssblk.c:81:28: error: storage class specified for parameter 'dcssblk_devices_sem'
    static struct rw_semaphore dcssblk_devices_sem;
                               ^
>> drivers/s390/block/dcssblk.c:88:1: error: expected '=', ',', ';', 'asm' or '__attribute__' before '{' token
    {
    ^
   drivers/s390/block/dcssblk.c:109:1: error: expected '=', ',', ';', 'asm' or '__attribute__' before '{' token
    {
    ^
   drivers/s390/block/dcssblk.c:136:1: error: expected '=', ',', ';', 'asm' or '__attribute__' before '{' token
    {
    ^
   drivers/s390/block/dcssblk.c:154:1: error: expected '=', ',', ';', 'asm' or '__attribute__' before '{' token
    {
    ^
   drivers/s390/block/dcssblk.c:172:1: error: expected '=', ',', ';', 'asm' or '__attribute__' before '{' token
    {
    ^
   drivers/s390/block/dcssblk.c:189:1: error: expected '=', ',', ';', 'asm' or '__attribute__' before '{' token
    {
    ^
   drivers/s390/block/dcssblk.c:213:1: error: expected '=', ',', ';', 'asm' or '__attribute__' before '{' token
    {
    ^
   drivers/s390/block/dcssblk.c:279:1: error: expected '=', ',', ';', 'asm' or '__attribute__' before '{' token
    {
    ^
   drivers/s390/block/dcssblk.c:315:1: error: expected '=', ',', ';', 'asm' or '__attribute__' before '{' token
    {
    ^
   drivers/s390/block/dcssblk.c:324:1: error: expected '=', ',', ';', 'asm' or '__attribute__' before '{' token
    {
    ^
   In file included from include/linux/genhd.h:63:0,
                    from include/linux/blkdev.h:9,
                    from drivers/s390/block/dcssblk.c:16:

vim +/dcssblk_segments +36 drivers/s390/block/dcssblk.c

^1da177e Linus Torvalds  2005-04-16  23  
^1da177e Linus Torvalds  2005-04-16  24  #define DCSSBLK_NAME "dcssblk"
^1da177e Linus Torvalds  2005-04-16  25  #define DCSSBLK_MINORS_PER_DISK 1
^1da177e Linus Torvalds  2005-04-16  26  #define DCSSBLK_PARM_LEN 400
98df67b3 Kay Sievers     2008-12-25  27  #define DCSS_BUS_ID_SIZE 20
^1da177e Linus Torvalds  2005-04-16  28  
46d74326 Al Viro         2008-03-02 @29  static int dcssblk_open(struct block_device *bdev, fmode_t mode);
db2a144b Al Viro         2013-05-05 @30  static void dcssblk_release(struct gendisk *disk, fmode_t mode);
dece1635 Jens Axboe      2015-11-05  31  static blk_qc_t dcssblk_make_request(struct request_queue *q,
dece1635 Jens Axboe      2015-11-05  32  						struct bio *bio);
e3cb53fb Dan Williams    2016-03-29 @33  static long dcssblk_direct_access(struct block_device *bdev,
e3cb53fb Dan Williams    2016-03-29  34  		struct blk_dax_ctl *dax)
^1da177e Linus Torvalds  2005-04-16  35  
^1da177e Linus Torvalds  2005-04-16 @36  static char dcssblk_segments[DCSSBLK_PARM_LEN] = "\0";
^1da177e Linus Torvalds  2005-04-16  37  
^1da177e Linus Torvalds  2005-04-16 @38  static int dcssblk_major;
83d5cde4 Alexey Dobriyan 2009-09-21 @39  static const struct block_device_operations dcssblk_devops = {
^1da177e Linus Torvalds  2005-04-16  40  	.owner   	= THIS_MODULE,
46d74326 Al Viro         2008-03-02  41  	.open    	= dcssblk_open,
46d74326 Al Viro         2008-03-02  42  	.release 	= dcssblk_release,
420edbcc Carsten Otte    2005-06-23  43  	.direct_access 	= dcssblk_direct_access,
^1da177e Linus Torvalds  2005-04-16  44  };
^1da177e Linus Torvalds  2005-04-16  45  
b2300b9e Hongjie Yang    2008-10-10 @46  struct dcssblk_dev_info {
b2300b9e Hongjie Yang    2008-10-10  47  	struct list_head lh;
b2300b9e Hongjie Yang    2008-10-10  48  	struct device dev;
98df67b3 Kay Sievers     2008-12-25  49  	char segment_name[DCSS_BUS_ID_SIZE];
b2300b9e Hongjie Yang    2008-10-10  50  	atomic_t use_count;
b2300b9e Hongjie Yang    2008-10-10  51  	struct gendisk *gd;
b2300b9e Hongjie Yang    2008-10-10  52  	unsigned long start;
b2300b9e Hongjie Yang    2008-10-10  53  	unsigned long end;
b2300b9e Hongjie Yang    2008-10-10  54  	int segment_type;
b2300b9e Hongjie Yang    2008-10-10  55  	unsigned char save_pending;
b2300b9e Hongjie Yang    2008-10-10  56  	unsigned char is_shared;
b2300b9e Hongjie Yang    2008-10-10  57  	struct request_queue *dcssblk_queue;
b2300b9e Hongjie Yang    2008-10-10  58  	int num_of_segments;
b2300b9e Hongjie Yang    2008-10-10  59  	struct list_head seg_list;
b2300b9e Hongjie Yang    2008-10-10  60  };
b2300b9e Hongjie Yang    2008-10-10  61  
b2300b9e Hongjie Yang    2008-10-10  62  struct segment_info {
b2300b9e Hongjie Yang    2008-10-10  63  	struct list_head lh;
98df67b3 Kay Sievers     2008-12-25  64  	char segment_name[DCSS_BUS_ID_SIZE];
b2300b9e Hongjie Yang    2008-10-10  65  	unsigned long start;
b2300b9e Hongjie Yang    2008-10-10  66  	unsigned long end;
b2300b9e Hongjie Yang    2008-10-10  67  	int segment_type;
b2300b9e Hongjie Yang    2008-10-10  68  };
b2300b9e Hongjie Yang    2008-10-10  69  
e404e274 Yani Ioannou    2005-05-17 @70  static ssize_t dcssblk_add_store(struct device * dev, struct device_attribute *attr, const char * buf,
^1da177e Linus Torvalds  2005-04-16  71  				  size_t count);
e404e274 Yani Ioannou    2005-05-17 @72  static ssize_t dcssblk_remove_store(struct device * dev, struct device_attribute *attr, const char * buf,
^1da177e Linus Torvalds  2005-04-16  73  				  size_t count);
^1da177e Linus Torvalds  2005-04-16  74  
^1da177e Linus Torvalds  2005-04-16 @75  static DEVICE_ATTR(add, S_IWUSR, NULL, dcssblk_add_store);
^1da177e Linus Torvalds  2005-04-16 @76  static DEVICE_ATTR(remove, S_IWUSR, NULL, dcssblk_remove_store);
^1da177e Linus Torvalds  2005-04-16  77  
^1da177e Linus Torvalds  2005-04-16 @78  static struct device *dcssblk_root_dev;
^1da177e Linus Torvalds  2005-04-16  79  
c11ca97e Denis Cheng     2008-01-26 @80  static LIST_HEAD(dcssblk_devices);
^1da177e Linus Torvalds  2005-04-16 @81  static struct rw_semaphore dcssblk_devices_sem;
^1da177e Linus Torvalds  2005-04-16  82  
^1da177e Linus Torvalds  2005-04-16  83  /*
^1da177e Linus Torvalds  2005-04-16  84   * release function for segment device.
^1da177e Linus Torvalds  2005-04-16  85   */
^1da177e Linus Torvalds  2005-04-16  86  static void
^1da177e Linus Torvalds  2005-04-16  87  dcssblk_release_segment(struct device *dev)
^1da177e Linus Torvalds  2005-04-16 @88  {
b2300b9e Hongjie Yang    2008-10-10  89  	struct dcssblk_dev_info *dev_info;
b2300b9e Hongjie Yang    2008-10-10  90  	struct segment_info *entry, *temp;
b2300b9e Hongjie Yang    2008-10-10  91  

:::::: The code at line 36 was first introduced by commit
:::::: 1da177e4c3f41524e886b7f1b8a0c1fc7321cac2 Linux-2.6.12-rc2

:::::: TO: Linus Torvalds <torvalds@ppc970.osdl.org>
:::::: CC: Linus Torvalds <torvalds@ppc970.osdl.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--ew6BAiZeqk4r7MaW
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--ew6BAiZeqk4r7MaW--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
