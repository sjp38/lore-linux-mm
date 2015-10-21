Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8C3686B0038
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 09:53:15 -0400 (EDT)
Received: by igdg1 with SMTP id g1so86679156igd.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 06:53:15 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id k198si7475661iok.43.2015.10.21.06.53.14
        for <linux-mm@kvack.org>;
        Wed, 21 Oct 2015 06:53:14 -0700 (PDT)
Date: Wed, 21 Oct 2015 21:48:40 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-review:Tetsuo-Handa/mm-vmscan-Use-accurate-values-for-zone_reclaimable-checks/20151021-203036
 9489/9695] include/linux/uaccess.h:88:13: error: storage class specified for
 parameter '__probe_kernel_read'
Message-ID: <201510212134.UwroVzAf%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="a8Wt8u1KmwUX3Y2C"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--a8Wt8u1KmwUX3Y2C
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Minchan,

[auto build test ERROR on v4.3-rc6-108-gce1fad2 -- if it's inappropriate base, please suggest rules for selecting the more suitable base]

url:    https://github.com/0day-ci/linux/commits/Tetsuo-Handa/mm-vmscan-Use-accurate-values-for-zone_reclaimable-checks/20151021-203036
config: microblaze-nommu_defconfig (attached as .config)
reproduce:
        wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
        chmod +x ~/bin/make.cross
        # save the attached .config to linux build tree
        make.cross ARCH=microblaze 

All error/warnings (new ones prefixed by >>):

   In file included from init/main.c:50:0:
   include/linux/rmap.h:274:1: error: expected declaration specifiers or '...' before '{' token
    {
    ^
   In file included from include/linux/highmem.h:8:0,
                    from include/linux/pagemap.h:10,
                    from include/linux/mempolicy.h:14,
                    from init/main.c:51:
>> include/linux/uaccess.h:88:13: error: storage class specified for parameter '__probe_kernel_read'
    extern long __probe_kernel_read(void *dst, const void *src, size_t size);
                ^
>> include/linux/uaccess.h:99:21: error: storage class specified for parameter 'probe_kernel_write'
    extern long notrace probe_kernel_write(void *dst, const void *src, size_t size);
                        ^
>> include/linux/uaccess.h:99:21: error: 'no_instrument_function' attribute applies only to functions
>> include/linux/uaccess.h:100:21: error: storage class specified for parameter '__probe_kernel_write'
    extern long notrace __probe_kernel_write(void *dst, const void *src, size_t size);
                        ^
   include/linux/uaccess.h:100:21: error: 'no_instrument_function' attribute applies only to functions
>> include/linux/uaccess.h:102:13: error: storage class specified for parameter 'strncpy_from_unsafe'
    extern long strncpy_from_unsafe(char *dst, const void *unsafe_addr, long count);
                ^
   In file included from include/linux/highmem.h:11:0,
                    from include/linux/pagemap.h:10,
                    from include/linux/mempolicy.h:14,
                    from init/main.c:51:
>> arch/microblaze/include/asm/cacheflush.h:53:23: error: storage class specified for parameter 'mbc'
    extern struct scache *mbc;
                          ^
>> arch/microblaze/include/asm/cacheflush.h:105:20: error: storage class specified for parameter 'copy_to_user_page'
    static inline void copy_to_user_page(struct vm_area_struct *vma,
                       ^
>> arch/microblaze/include/asm/cacheflush.h:105:20: warning: parameter 'copy_to_user_page' declared 'inline'
>> arch/microblaze/include/asm/cacheflush.h:108:1: warning: 'always_inline' attribute ignored [-Wattributes]
    {
    ^
>> arch/microblaze/include/asm/cacheflush.h:105:20: error: 'no_instrument_function' attribute applies only to functions
    static inline void copy_to_user_page(struct vm_area_struct *vma,
                       ^
>> arch/microblaze/include/asm/cacheflush.h:108:1: error: expected ';', ',' or ')' before '{' token
    {
    ^
--
   In file included from kernel/fork.c:55:0:
   include/linux/rmap.h:274:1: error: expected declaration specifiers or '...' before '{' token
    {
    ^
   In file included from kernel/fork.c:56:0:
>> include/linux/ksm.h:69:19: error: storage class specified for parameter 'ksm_fork'
    static inline int ksm_fork(struct mm_struct *mm, struct mm_struct *oldmm)
                      ^
>> include/linux/ksm.h:69:19: warning: parameter 'ksm_fork' declared 'inline'
>> include/linux/ksm.h:70:1: warning: 'always_inline' attribute ignored [-Wattributes]
    {
    ^
>> include/linux/ksm.h:69:19: error: 'no_instrument_function' attribute applies only to functions
    static inline int ksm_fork(struct mm_struct *mm, struct mm_struct *oldmm)
                      ^
>> include/linux/ksm.h:70:1: error: expected ';', ',' or ')' before '{' token
    {
    ^
--
   In file included from mm/filemap.c:36:0:
   include/linux/rmap.h:274:1: error: expected declaration specifiers or '...' before '{' token
    {
    ^
   In file included from mm/filemap.c:37:0:
>> mm/internal.h:44:20: error: storage class specified for parameter 'set_page_count'
    static inline void set_page_count(struct page *page, int v)
                       ^
>> mm/internal.h:44:20: warning: parameter 'set_page_count' declared 'inline'
>> mm/internal.h:45:1: warning: 'always_inline' attribute ignored [-Wattributes]
    {
    ^
>> mm/internal.h:44:20: error: 'no_instrument_function' attribute applies only to functions
    static inline void set_page_count(struct page *page, int v)
                       ^
>> mm/internal.h:45:1: error: expected ';', ',' or ')' before '{' token
    {
    ^
--
   In file included from mm/interval_tree.c:11:0:
   include/linux/rmap.h:274:1: error: expected declaration specifiers or '...' before '{' token
    {
    ^
   In file included from include/linux/interval_tree_generic.h:22:0,
                    from mm/interval_tree.c:12:
>> include/linux/rbtree_augmented.h:44:13: error: storage class specified for parameter '__rb_insert_augmented'
    extern void __rb_insert_augmented(struct rb_node *node, struct rb_root *root,
                ^
>> include/linux/rbtree_augmented.h:58:20: warning: 'struct rb_augment_callbacks' declared inside parameter list
          const struct rb_augment_callbacks *augment)
                       ^
>> include/linux/rbtree_augmented.h:58:20: warning: its scope is only this definition or declaration, which is probably not what you want
>> include/linux/rbtree_augmented.h:57:1: error: storage class specified for parameter 'rb_insert_augmented'
    rb_insert_augmented(struct rb_node *node, struct rb_root *root,
    ^
>> include/linux/rbtree_augmented.h:57:1: warning: parameter 'rb_insert_augmented' declared 'inline'
>> include/linux/rbtree_augmented.h:59:1: warning: 'always_inline' attribute ignored [-Wattributes]
    {
    ^
>> include/linux/rbtree_augmented.h:57:1: error: 'no_instrument_function' attribute applies only to functions
    rb_insert_augmented(struct rb_node *node, struct rb_root *root,
    ^
>> include/linux/rbtree_augmented.h:59:1: error: expected ';', ',' or ')' before '{' token
    {
    ^

vim +/__probe_kernel_read +88 include/linux/uaccess.h

c33fa9f5 Ingo Molnar        2008-04-17   82   * @size: size of the data chunk
c33fa9f5 Ingo Molnar        2008-04-17   83   *
c33fa9f5 Ingo Molnar        2008-04-17   84   * Safely read from address @src to the buffer at @dst.  If a kernel fault
c33fa9f5 Ingo Molnar        2008-04-17   85   * happens, handle that and return -EFAULT.
c33fa9f5 Ingo Molnar        2008-04-17   86   */
f29c5041 Steven Rostedt     2011-05-19   87  extern long probe_kernel_read(void *dst, const void *src, size_t size);
f29c5041 Steven Rostedt     2011-05-19  @88  extern long __probe_kernel_read(void *dst, const void *src, size_t size);
c33fa9f5 Ingo Molnar        2008-04-17   89  
c33fa9f5 Ingo Molnar        2008-04-17   90  /*
c33fa9f5 Ingo Molnar        2008-04-17   91   * probe_kernel_write(): safely attempt to write to a location
c33fa9f5 Ingo Molnar        2008-04-17   92   * @dst: address to write to
c33fa9f5 Ingo Molnar        2008-04-17   93   * @src: pointer to the data that shall be written
c33fa9f5 Ingo Molnar        2008-04-17   94   * @size: size of the data chunk
c33fa9f5 Ingo Molnar        2008-04-17   95   *
c33fa9f5 Ingo Molnar        2008-04-17   96   * Safely write to address @dst from the buffer at @src.  If a kernel fault
c33fa9f5 Ingo Molnar        2008-04-17   97   * happens, handle that and return -EFAULT.
c33fa9f5 Ingo Molnar        2008-04-17   98   */
f29c5041 Steven Rostedt     2011-05-19  @99  extern long notrace probe_kernel_write(void *dst, const void *src, size_t size);
f29c5041 Steven Rostedt     2011-05-19 @100  extern long notrace __probe_kernel_write(void *dst, const void *src, size_t size);
c33fa9f5 Ingo Molnar        2008-04-17  101  
1a6877b9 Alexei Starovoitov 2015-08-28 @102  extern long strncpy_from_unsafe(char *dst, const void *unsafe_addr, long count);
1a6877b9 Alexei Starovoitov 2015-08-28  103  
43cc247b Andrew Morton      2015-10-21  104  /**
43cc247b Andrew Morton      2015-10-21  105   * probe_kernel_address(): safely attempt to read from a location

:::::: The code at line 88 was first introduced by commit
:::::: f29c50419c8d1998edd759f1990c4243a248f469 maccess,probe_kernel: Make write/read src const void *

:::::: TO: Steven Rostedt <srostedt@redhat.com>
:::::: CC: Steven Rostedt <rostedt@goodmis.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--a8Wt8u1KmwUX3Y2C
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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

--a8Wt8u1KmwUX3Y2C--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
