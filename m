Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 665AD6B0265
	for <linux-mm@kvack.org>; Wed, 25 May 2016 03:30:54 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id x1so49508400pav.3
        for <linux-mm@kvack.org>; Wed, 25 May 2016 00:30:54 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id l19si4818157pfb.167.2016.05.25.00.30.51
        for <linux-mm@kvack.org>;
        Wed, 25 May 2016 00:30:51 -0700 (PDT)
Date: Wed, 25 May 2016 15:30:14 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-next:master 11895/11991] fs/proc/task_mmu.c:933:3: error:
 implicit declaration of function 'test_and_clear_page_young'
Message-ID: <201605251510.Ed9zA6So%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="17pEHd4RhPHOinZp"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: kbuild-all@01.org, Yang Shi <yang.shi@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>


--17pEHd4RhPHOinZp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

tree:   https://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git master
head:   66c198deda3725c57939c6cdaf2c9f5375cd79ad
commit: 38c4fffbad3cbfc55e9e69d5e304c82baced199a [11895/11991] mm: check the return value of lookup_page_ext for all call sites
config: i386-randconfig-x0-05251403 (attached as .config)
compiler: gcc-6 (Debian 6.1.1-1) 6.1.1 20160430
reproduce:
        git checkout 38c4fffbad3cbfc55e9e69d5e304c82baced199a
        # save the attached .config to linux build tree
        make ARCH=i386 

Note: the linux-next/master HEAD 66c198deda3725c57939c6cdaf2c9f5375cd79ad builds fine.
      It may have been fixed somewhere.

All error/warnings (new ones prefixed by >>):

                       ^~~~~~~~~~~~~
   In file included from fs/proc/task_mmu.c:22:0:
   fs/proc/internal.h:69:15: error: field 'vfs_inode' has incomplete type
     struct inode vfs_inode;
                  ^~~~~~~~~
   fs/proc/internal.h:75:34: error: invalid storage class for function 'PROC_I'
    static inline struct proc_inode *PROC_I(const struct inode *inode)
                                     ^~~~~~
   In file included from include/asm-generic/bug.h:13:0,
                    from arch/x86/include/asm/bug.h:35,
                    from include/linux/bug.h:4,
                    from include/linux/mmdebug.h:4,
                    from include/linux/mm.h:8,
                    from fs/proc/task_mmu.c:1:
   fs/proc/internal.h: In function 'PROC_I':
   include/linux/kernel.h:831:48: error: initialization from incompatible pointer type [-Werror=incompatible-pointer-types]
     const typeof( ((type *)0)->member ) *__mptr = (ptr); \
                                                   ^
   fs/proc/internal.h:77:9: note: in expansion of macro 'container_of'
     return container_of(inode, struct proc_inode, vfs_inode);
            ^~~~~~~~~~~~
   In file included from fs/proc/task_mmu.c:22:0:
   fs/proc/internal.h: In function 'page_is_young':
   fs/proc/internal.h:80:38: error: invalid storage class for function 'PDE'
    static inline struct proc_dir_entry *PDE(const struct inode *inode)
                                         ^~~
   fs/proc/internal.h:85:21: error: invalid storage class for function '__PDE_DATA'
    static inline void *__PDE_DATA(const struct inode *inode)
                        ^~~~~~~~~~
   fs/proc/internal.h:90:27: error: invalid storage class for function 'proc_pid'
    static inline struct pid *proc_pid(struct inode *inode)
                              ^~~~~~~~
   fs/proc/internal.h:95:35: error: invalid storage class for function 'get_proc_task'
    static inline struct task_struct *get_proc_task(struct inode *inode)
                                      ^~~~~~~~~~~~~
   fs/proc/internal.h: In function 'get_proc_task':
   fs/proc/internal.h:97:9: error: return from incompatible pointer type [-Werror=incompatible-pointer-types]
     return get_pid_task(proc_pid(inode), PIDTYPE_PID);
            ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
   fs/proc/internal.h: In function 'page_is_young':
   fs/proc/internal.h:100:19: error: invalid storage class for function 'task_dumpable'
    static inline int task_dumpable(struct task_struct *task)
                      ^~~~~~~~~~~~~
   fs/proc/internal.h: In function 'task_dumpable':
   fs/proc/internal.h:105:12: error: passing argument 1 of 'task_lock' from incompatible pointer type [-Werror=incompatible-pointer-types]
     task_lock(task);
               ^~~~
   In file included from include/linux/vmacache.h:4:0,
                    from fs/proc/task_mmu.c:2:
   include/linux/sched.h:2914:20: note: expected 'struct task_struct *' but argument is of type 'struct task_struct *'
    static inline void task_lock(struct task_struct *p)
                       ^~~~~~~~~
   In file included from fs/proc/task_mmu.c:22:0:
   fs/proc/internal.h:106:11: error: dereferencing pointer to incomplete type 'struct task_struct'
     mm = task->mm;
              ^~
   fs/proc/internal.h:109:14: error: passing argument 1 of 'task_unlock' from incompatible pointer type [-Werror=incompatible-pointer-types]
     task_unlock(task);
                 ^~~~
   In file included from include/linux/vmacache.h:4:0,
                    from fs/proc/task_mmu.c:2:
   include/linux/sched.h:2919:20: note: expected 'struct task_struct *' but argument is of type 'struct task_struct *'
    static inline void task_unlock(struct task_struct *p)
                       ^~~~~~~~~~~
   In file included from fs/proc/task_mmu.c:22:0:
   fs/proc/internal.h: In function 'page_is_young':
   fs/proc/internal.h:115:24: error: invalid storage class for function 'name_to_int'
    static inline unsigned name_to_int(const struct qstr *qstr)
                           ^~~~~~~~~~~
   fs/proc/internal.h:187:38: error: invalid storage class for function 'pde_get'
    static inline struct proc_dir_entry *pde_get(struct proc_dir_entry *pde)
                                         ^~~~~~~
   fs/proc/internal.h:194:20: error: invalid storage class for function 'is_empty_pde'
    static inline bool is_empty_pde(const struct proc_dir_entry *pde)
                       ^~~~~~~~~~~~
   fs/proc/task_mmu.c:24:6: error: static declaration of 'task_mem' follows non-static declaration
    void task_mem(struct seq_file *m, struct mm_struct *mm)
         ^~~~~~~~
   In file included from fs/proc/task_mmu.c:22:0:
   fs/proc/internal.h:305:13: note: previous declaration of 'task_mem' was here
    extern void task_mem(struct seq_file *, struct mm_struct *);
                ^~~~~~~~
   fs/proc/task_mmu.c:86:15: error: static declaration of 'task_vsize' follows non-static declaration
    unsigned long task_vsize(struct mm_struct *mm)
                  ^~~~~~~~~~
   In file included from fs/proc/task_mmu.c:22:0:
   fs/proc/internal.h:301:22: note: previous declaration of 'task_vsize' was here
    extern unsigned long task_vsize(struct mm_struct *);
                         ^~~~~~~~~~
   fs/proc/task_mmu.c:91:15: error: static declaration of 'task_statm' follows non-static declaration
    unsigned long task_statm(struct mm_struct *mm,
                  ^~~~~~~~~~
   In file included from fs/proc/task_mmu.c:22:0:
   fs/proc/internal.h:302:22: note: previous declaration of 'task_statm' was here
    extern unsigned long task_statm(struct mm_struct *,
                         ^~~~~~~~~~
   fs/proc/task_mmu.c:108:13: error: invalid storage class for function 'hold_task_mempolicy'
    static void hold_task_mempolicy(struct proc_maps_private *priv)
                ^~~~~~~~~~~~~~~~~~~
   fs/proc/task_mmu.c: In function 'hold_task_mempolicy':
>> fs/proc/task_mmu.c:112:12: error: passing argument 1 of 'task_lock' from incompatible pointer type [-Werror=incompatible-pointer-types]
     task_lock(task);
               ^~~~
   In file included from include/linux/vmacache.h:4:0,
                    from fs/proc/task_mmu.c:2:
   include/linux/sched.h:2914:20: note: expected 'struct task_struct *' but argument is of type 'struct task_struct *'
    static inline void task_lock(struct task_struct *p)
                       ^~~~~~~~~
>> fs/proc/task_mmu.c:113:41: error: passing argument 1 of 'get_task_policy' from incompatible pointer type [-Werror=incompatible-pointer-types]
     priv->task_mempolicy = get_task_policy(task);
                                            ^~~~
   In file included from include/linux/hugetlb.h:19:0,
                    from fs/proc/task_mmu.c:3:
   include/linux/mempolicy.h:137:19: note: expected 'struct task_struct *' but argument is of type 'struct task_struct *'
    struct mempolicy *get_task_policy(struct task_struct *p);
                      ^~~~~~~~~~~~~~~
   fs/proc/task_mmu.c:113:23: error: assignment from incompatible pointer type [-Werror=incompatible-pointer-types]
     priv->task_mempolicy = get_task_policy(task);
                          ^
>> fs/proc/task_mmu.c:114:11: error: passing argument 1 of 'mpol_get' from incompatible pointer type [-Werror=incompatible-pointer-types]
     mpol_get(priv->task_mempolicy);
              ^~~~
   In file included from include/linux/hugetlb.h:19:0,
                    from fs/proc/task_mmu.c:3:
   include/linux/mempolicy.h:95:20: note: expected 'struct mempolicy *' but argument is of type 'struct mempolicy *'
    static inline void mpol_get(struct mempolicy *pol)
                       ^~~~~~~~
>> fs/proc/task_mmu.c:115:14: error: passing argument 1 of 'task_unlock' from incompatible pointer type [-Werror=incompatible-pointer-types]
     task_unlock(task);
                 ^~~~
   In file included from include/linux/vmacache.h:4:0,
                    from fs/proc/task_mmu.c:2:
   include/linux/sched.h:2919:20: note: expected 'struct task_struct *' but argument is of type 'struct task_struct *'
    static inline void task_unlock(struct task_struct *p)
                       ^~~~~~~~~~~
   fs/proc/task_mmu.c: In function 'page_is_young':
   fs/proc/task_mmu.c:117:13: error: invalid storage class for function 'release_task_mempolicy'
    static void release_task_mempolicy(struct proc_maps_private *priv)
                ^~~~~~~~~~~~~~~~~~~~~~
   fs/proc/task_mmu.c: In function 'release_task_mempolicy':
>> fs/proc/task_mmu.c:119:11: error: passing argument 1 of 'mpol_put' from incompatible pointer type [-Werror=incompatible-pointer-types]
     mpol_put(priv->task_mempolicy);
              ^~~~
   In file included from include/linux/hugetlb.h:19:0,
                    from fs/proc/task_mmu.c:3:
   include/linux/mempolicy.h:64:20: note: expected 'struct mempolicy *' but argument is of type 'struct mempolicy *'
    static inline void mpol_put(struct mempolicy *pol)
                       ^~~~~~~~
   fs/proc/task_mmu.c: In function 'page_is_young':
   fs/proc/task_mmu.c:130:13: error: invalid storage class for function 'vma_stop'
    static void vma_stop(struct proc_maps_private *priv)
                ^~~~~~~~
   fs/proc/task_mmu.c:140:1: error: invalid storage class for function 'm_next_vma'
    m_next_vma(struct proc_maps_private *priv, struct vm_area_struct *vma)
    ^~~~~~~~~~
   fs/proc/task_mmu.c:147:13: error: invalid storage class for function 'm_cache_vma'
    static void m_cache_vma(struct seq_file *m, struct vm_area_struct *vma)
                ^~~~~~~~~~~
   fs/proc/task_mmu.c:153:14: error: invalid storage class for function 'm_start'
    static void *m_start(struct seq_file *m, loff_t *ppos)
                 ^~~~~~~
   fs/proc/task_mmu.c:200:14: error: invalid storage class for function 'm_next'
    static void *m_next(struct seq_file *m, void *v, loff_t *pos)
                 ^~~~~~
   fs/proc/task_mmu.c:212:13: error: invalid storage class for function 'm_stop'
    static void m_stop(struct seq_file *m, void *v)
                ^~~~~~
   fs/proc/task_mmu.c: In function 'm_stop':
   fs/proc/task_mmu.c:219:19: error: passing argument 1 of 'put_task_struct' from incompatible pointer type [-Werror=incompatible-pointer-types]
      put_task_struct(priv->task);
                      ^~~~
   In file included from include/linux/vmacache.h:4:0,
                    from fs/proc/task_mmu.c:2:
   include/linux/sched.h:2137:20: note: expected 'struct task_struct *' but argument is of type 'struct task_struct *'
    static inline void put_task_struct(struct task_struct *t)
                       ^~~~~~~~~~~~~~~
   fs/proc/task_mmu.c: In function 'page_is_young':
   fs/proc/task_mmu.c:224:12: error: invalid storage class for function 'proc_maps_open'
    static int proc_maps_open(struct inode *inode, struct file *file,
               ^~~~~~~~~~~~~~
   fs/proc/task_mmu.c: In function 'proc_maps_open':
   fs/proc/task_mmu.c:237:23: error: passing argument 1 of 'seq_release_private' from incompatible pointer type [-Werror=incompatible-pointer-types]
      seq_release_private(inode, file);
                          ^~~~~
   In file included from include/linux/cgroup.h:17:0,
                    from include/linux/hugetlb.h:8,
                    from fs/proc/task_mmu.c:3:
   include/linux/seq_file.h:140:5: note: expected 'struct inode *' but argument is of type 'struct inode *'
    int seq_release_private(struct inode *, struct file *);
        ^~~~~~~~~~~~~~~~~~~
   fs/proc/task_mmu.c: In function 'page_is_young':
   fs/proc/task_mmu.c:244:12: error: invalid storage class for function 'proc_map_release'
    static int proc_map_release(struct inode *inode, struct file *file)
               ^~~~~~~~~~~~~~~~
   fs/proc/task_mmu.c: In function 'proc_map_release':
   fs/proc/task_mmu.c:252:29: error: passing argument 1 of 'seq_release_private' from incompatible pointer type [-Werror=incompatible-pointer-types]
     return seq_release_private(inode, file);
                                ^~~~~
   In file included from include/linux/cgroup.h:17:0,
                    from include/linux/hugetlb.h:8,
                    from fs/proc/task_mmu.c:3:
   include/linux/seq_file.h:140:5: note: expected 'struct inode *' but argument is of type 'struct inode *'
    int seq_release_private(struct inode *, struct file *);
        ^~~~~~~~~~~~~~~~~~~
   fs/proc/task_mmu.c: In function 'page_is_young':
   fs/proc/task_mmu.c:255:12: error: invalid storage class for function 'do_maps_open'
    static int do_maps_open(struct inode *inode, struct file *file,
               ^~~~~~~~~~~~
   fs/proc/task_mmu.c:266:12: error: invalid storage class for function 'is_stack'
    static int is_stack(struct proc_maps_private *priv,
               ^~~~~~~~
   fs/proc/task_mmu.c: In function 'is_stack':
   fs/proc/task_mmu.c:279:8: error: assignment from incompatible pointer type [-Werror=incompatible-pointer-types]
      task = pid_task(proc_pid(inode), PIDTYPE_PID);
           ^
   fs/proc/task_mmu.c:281:39: error: passing argument 2 of 'vma_is_stack_for_task' from incompatible pointer type [-Werror=incompatible-pointer-types]
       stack = vma_is_stack_for_task(vma, task);
                                          ^~~~
   In file included from fs/proc/task_mmu.c:1:0:
   include/linux/mm.h:1367:5: note: expected 'struct task_struct *' but argument is of type 'struct task_struct *'
    int vma_is_stack_for_task(struct vm_area_struct *vma, struct task_struct *t);
        ^~~~~~~~~~~~~~~~~~~~~
   fs/proc/task_mmu.c: In function 'page_is_young':
   fs/proc/task_mmu.c:288:1: error: invalid storage class for function 'show_map_vma'
    show_map_vma(struct seq_file *m, struct vm_area_struct *vma, int is_pid)
    ^~~~~~~~~~~~
   fs/proc/task_mmu.c: In function 'show_map_vma':
   fs/proc/task_mmu.c:301:25: error: initialization from incompatible pointer type [-Werror=incompatible-pointer-types]
      struct inode *inode = file_inode(vma->vm_file);
                            ^~~~~~~~~~
   fs/proc/task_mmu.c:302:14: error: dereferencing pointer to incomplete type 'struct inode'
      dev = inode->i_sb->s_dev;
                 ^~
   fs/proc/task_mmu.c: In function 'page_is_young':
   fs/proc/task_mmu.c:367:12: error: invalid storage class for function 'show_map'
    static int show_map(struct seq_file *m, void *v, int is_pid)
               ^~~~~~~~
   fs/proc/task_mmu.c:374:12: error: invalid storage class for function 'show_pid_map'
    static int show_pid_map(struct seq_file *m, void *v)
               ^~~~~~~~~~~~
   fs/proc/task_mmu.c:379:12: error: invalid storage class for function 'show_tid_map'
--
   fs/proc/task_mmu.c:393:10: error: initializer element is not constant
     .next = m_next,
             ^~~~~~
   fs/proc/task_mmu.c:393:10: note: (near initialization for 'proc_tid_maps_op.next')
   fs/proc/task_mmu.c:394:10: error: initializer element is not constant
     .stop = m_stop,
             ^~~~~~
   fs/proc/task_mmu.c:394:10: note: (near initialization for 'proc_tid_maps_op.stop')
   fs/proc/task_mmu.c:395:10: error: initializer element is not constant
     .show = show_tid_map
             ^~~~~~~~~~~~
   fs/proc/task_mmu.c:395:10: note: (near initialization for 'proc_tid_maps_op.show')
   fs/proc/task_mmu.c:398:12: error: invalid storage class for function 'pid_maps_open'
    static int pid_maps_open(struct inode *inode, struct file *file)
               ^~~~~~~~~~~~~
   fs/proc/task_mmu.c:403:12: error: invalid storage class for function 'tid_maps_open'
    static int tid_maps_open(struct inode *inode, struct file *file)
               ^~~~~~~~~~~~~
   fs/proc/task_mmu.c:408:14: error: variable 'proc_pid_maps_operations' has initializer but incomplete type
    const struct file_operations proc_pid_maps_operations = {
                 ^~~~~~~~~~~~~~~
   fs/proc/task_mmu.c:408:30: error: declaration of 'proc_pid_maps_operations' with no linkage follows extern declaration
    const struct file_operations proc_pid_maps_operations = {
                                 ^~~~~~~~~~~~~~~~~~~~~~~~
   In file included from fs/proc/task_mmu.c:22:0:
   fs/proc/internal.h:292:37: note: previous declaration of 'proc_pid_maps_operations' was here
    extern const struct file_operations proc_pid_maps_operations;
                                        ^~~~~~~~~~~~~~~~~~~~~~~~
   fs/proc/task_mmu.c:409:2: error: unknown field 'open' specified in initializer
     .open  = pid_maps_open,
     ^
   fs/proc/task_mmu.c:409:11: warning: excess elements in struct initializer
     .open  = pid_maps_open,
              ^~~~~~~~~~~~~
   fs/proc/task_mmu.c:409:11: note: (near initialization for 'proc_pid_maps_operations')
   fs/proc/task_mmu.c:410:2: error: unknown field 'read' specified in initializer
     .read  = seq_read,
     ^
   fs/proc/task_mmu.c:410:11: warning: excess elements in struct initializer
     .read  = seq_read,
              ^~~~~~~~
   fs/proc/task_mmu.c:410:11: note: (near initialization for 'proc_pid_maps_operations')
   fs/proc/task_mmu.c:411:2: error: unknown field 'llseek' specified in initializer
     .llseek  = seq_lseek,
     ^
   fs/proc/task_mmu.c:411:13: warning: excess elements in struct initializer
     .llseek  = seq_lseek,
                ^~~~~~~~~
   fs/proc/task_mmu.c:411:13: note: (near initialization for 'proc_pid_maps_operations')
   fs/proc/task_mmu.c:412:2: error: unknown field 'release' specified in initializer
     .release = proc_map_release,
     ^
   fs/proc/task_mmu.c:412:13: warning: excess elements in struct initializer
     .release = proc_map_release,
                ^~~~~~~~~~~~~~~~
   fs/proc/task_mmu.c:412:13: note: (near initialization for 'proc_pid_maps_operations')
   fs/proc/task_mmu.c:408:30: error: storage size of 'proc_pid_maps_operations' isn't known
    const struct file_operations proc_pid_maps_operations = {
                                 ^~~~~~~~~~~~~~~~~~~~~~~~
   fs/proc/task_mmu.c:415:14: error: variable 'proc_tid_maps_operations' has initializer but incomplete type
    const struct file_operations proc_tid_maps_operations = {
                 ^~~~~~~~~~~~~~~
   fs/proc/task_mmu.c:415:30: error: declaration of 'proc_tid_maps_operations' with no linkage follows extern declaration
    const struct file_operations proc_tid_maps_operations = {
                                 ^~~~~~~~~~~~~~~~~~~~~~~~
   In file included from fs/proc/task_mmu.c:22:0:
   fs/proc/internal.h:293:37: note: previous declaration of 'proc_tid_maps_operations' was here
    extern const struct file_operations proc_tid_maps_operations;
                                        ^~~~~~~~~~~~~~~~~~~~~~~~
   fs/proc/task_mmu.c:416:2: error: unknown field 'open' specified in initializer
     .open  = tid_maps_open,
     ^
   fs/proc/task_mmu.c:416:11: warning: excess elements in struct initializer
     .open  = tid_maps_open,
              ^~~~~~~~~~~~~
   fs/proc/task_mmu.c:416:11: note: (near initialization for 'proc_tid_maps_operations')
   fs/proc/task_mmu.c:417:2: error: unknown field 'read' specified in initializer
     .read  = seq_read,
     ^
   fs/proc/task_mmu.c:417:11: warning: excess elements in struct initializer
     .read  = seq_read,
              ^~~~~~~~
   fs/proc/task_mmu.c:417:11: note: (near initialization for 'proc_tid_maps_operations')
   fs/proc/task_mmu.c:418:2: error: unknown field 'llseek' specified in initializer
     .llseek  = seq_lseek,
     ^
   fs/proc/task_mmu.c:418:13: warning: excess elements in struct initializer
     .llseek  = seq_lseek,
                ^~~~~~~~~
   fs/proc/task_mmu.c:418:13: note: (near initialization for 'proc_tid_maps_operations')
   fs/proc/task_mmu.c:419:2: error: unknown field 'release' specified in initializer
     .release = proc_map_release,
     ^
   fs/proc/task_mmu.c:419:13: warning: excess elements in struct initializer
     .release = proc_map_release,
                ^~~~~~~~~~~~~~~~
   fs/proc/task_mmu.c:419:13: note: (near initialization for 'proc_tid_maps_operations')
   fs/proc/task_mmu.c:415:30: error: storage size of 'proc_tid_maps_operations' isn't known
    const struct file_operations proc_tid_maps_operations = {
                                 ^~~~~~~~~~~~~~~~~~~~~~~~
>> fs/proc/task_mmu.c:459:13: error: invalid storage class for function 'smaps_account'
    static void smaps_account(struct mem_size_stats *mss, struct page *page,
                ^~~~~~~~~~~~~
>> fs/proc/task_mmu.c:507:12: error: invalid storage class for function 'smaps_pte_hole'
    static int smaps_pte_hole(unsigned long addr, unsigned long end,
               ^~~~~~~~~~~~~~
>> fs/proc/task_mmu.c:519:13: error: invalid storage class for function 'smaps_pte_entry'
    static void smaps_pte_entry(pte_t *pte, unsigned long addr,
                ^~~~~~~~~~~~~~~
>> fs/proc/task_mmu.c:583:13: error: invalid storage class for function 'smaps_pmd_entry'
    static void smaps_pmd_entry(pmd_t *pmd, unsigned long addr,
                ^~~~~~~~~~~~~~~
>> fs/proc/task_mmu.c:589:12: error: invalid storage class for function 'smaps_pte_range'
    static int smaps_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
               ^~~~~~~~~~~~~~~
>> fs/proc/task_mmu.c:618:13: error: invalid storage class for function 'show_smap_vma_flags'
    static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
                ^~~~~~~~~~~~~~~~~~~
>> fs/proc/task_mmu.c:686:12: error: invalid storage class for function 'smaps_hugetlb_range'
    static int smaps_hugetlb_range(pte_t *pte, unsigned long hmask,
               ^~~~~~~~~~~~~~~~~~~
>> fs/proc/task_mmu.c:718:12: error: invalid storage class for function 'show_smap'
    static int show_smap(struct seq_file *m, void *v, int is_pid)
               ^~~~~~~~~
>> fs/proc/task_mmu.c:805:12: error: invalid storage class for function 'show_pid_smap'
    static int show_pid_smap(struct seq_file *m, void *v)
               ^~~~~~~~~~~~~
>> fs/proc/task_mmu.c:810:12: error: invalid storage class for function 'show_tid_smap'
    static int show_tid_smap(struct seq_file *m, void *v)
               ^~~~~~~~~~~~~
   fs/proc/task_mmu.c:816:11: error: initializer element is not constant
     .start = m_start,
              ^~~~~~~
   fs/proc/task_mmu.c:816:11: note: (near initialization for 'proc_pid_smaps_op.start')
   fs/proc/task_mmu.c:817:10: error: initializer element is not constant
     .next = m_next,
             ^~~~~~
   fs/proc/task_mmu.c:817:10: note: (near initialization for 'proc_pid_smaps_op.next')
   fs/proc/task_mmu.c:818:10: error: initializer element is not constant
     .stop = m_stop,
             ^~~~~~
   fs/proc/task_mmu.c:818:10: note: (near initialization for 'proc_pid_smaps_op.stop')
   fs/proc/task_mmu.c:819:10: error: initializer element is not constant
     .show = show_pid_smap
             ^~~~~~~~~~~~~
   fs/proc/task_mmu.c:819:10: note: (near initialization for 'proc_pid_smaps_op.show')
   fs/proc/task_mmu.c:823:11: error: initializer element is not constant
     .start = m_start,
              ^~~~~~~
   fs/proc/task_mmu.c:823:11: note: (near initialization for 'proc_tid_smaps_op.start')
   fs/proc/task_mmu.c:824:10: error: initializer element is not constant
     .next = m_next,
             ^~~~~~
   fs/proc/task_mmu.c:824:10: note: (near initialization for 'proc_tid_smaps_op.next')
   fs/proc/task_mmu.c:825:10: error: initializer element is not constant
     .stop = m_stop,
             ^~~~~~
   fs/proc/task_mmu.c:825:10: note: (near initialization for 'proc_tid_smaps_op.stop')
   fs/proc/task_mmu.c:826:10: error: initializer element is not constant
     .show = show_tid_smap
             ^~~~~~~~~~~~~
   fs/proc/task_mmu.c:826:10: note: (near initialization for 'proc_tid_smaps_op.show')
>> fs/proc/task_mmu.c:829:12: error: invalid storage class for function 'pid_smaps_open'
    static int pid_smaps_open(struct inode *inode, struct file *file)
               ^~~~~~~~~~~~~~
>> fs/proc/task_mmu.c:834:12: error: invalid storage class for function 'tid_smaps_open'
    static int tid_smaps_open(struct inode *inode, struct file *file)
               ^~~~~~~~~~~~~~
>> fs/proc/task_mmu.c:839:14: error: variable 'proc_pid_smaps_operations' has initializer but incomplete type
    const struct file_operations proc_pid_smaps_operations = {
                 ^~~~~~~~~~~~~~~
>> fs/proc/task_mmu.c:839:30: error: declaration of 'proc_pid_smaps_operations' with no linkage follows extern declaration
    const struct file_operations proc_pid_smaps_operations = {
                                 ^~~~~~~~~~~~~~~~~~~~~~~~~
   In file included from fs/proc/task_mmu.c:22:0:
   fs/proc/internal.h:296:37: note: previous declaration of 'proc_pid_smaps_operations' was here
    extern const struct file_operations proc_pid_smaps_operations;
                                        ^~~~~~~~~~~~~~~~~~~~~~~~~
   fs/proc/task_mmu.c:840:2: error: unknown field 'open' specified in initializer
     .open  = pid_smaps_open,
     ^
   fs/proc/task_mmu.c:840:11: warning: excess elements in struct initializer
     .open  = pid_smaps_open,
              ^~~~~~~~~~~~~~
   fs/proc/task_mmu.c:840:11: note: (near initialization for 'proc_pid_smaps_operations')
   fs/proc/task_mmu.c:841:2: error: unknown field 'read' specified in initializer
     .read  = seq_read,
     ^
   fs/proc/task_mmu.c:841:11: warning: excess elements in struct initializer
     .read  = seq_read,
              ^~~~~~~~
   fs/proc/task_mmu.c:841:11: note: (near initialization for 'proc_pid_smaps_operations')
   fs/proc/task_mmu.c:842:2: error: unknown field 'llseek' specified in initializer
     .llseek  = seq_lseek,
     ^
   fs/proc/task_mmu.c:842:13: warning: excess elements in struct initializer
     .llseek  = seq_lseek,
                ^~~~~~~~~
   fs/proc/task_mmu.c:842:13: note: (near initialization for 'proc_pid_smaps_operations')
   fs/proc/task_mmu.c:843:2: error: unknown field 'release' specified in initializer
     .release = proc_map_release,
     ^
   fs/proc/task_mmu.c:843:13: warning: excess elements in struct initializer
     .release = proc_map_release,
                ^~~~~~~~~~~~~~~~
   fs/proc/task_mmu.c:843:13: note: (near initialization for 'proc_pid_smaps_operations')
>> fs/proc/task_mmu.c:839:30: error: storage size of 'proc_pid_smaps_operations' isn't known
    const struct file_operations proc_pid_smaps_operations = {
                                 ^~~~~~~~~~~~~~~~~~~~~~~~~
..

vim +/test_and_clear_page_young +933 fs/proc/task_mmu.c

c1192f842 Dave Hansen           2016-02-12   799  	arch_show_smap(m, vma);
834f82e2a Cyrill Gorcunov       2012-12-17   800  	show_smap_vma_flags(m, vma);
b8c20a9b8 Oleg Nesterov         2014-10-09   801  	m_cache_vma(m, vma);
7c88db0cb Joe Korty             2008-10-16   802  	return 0;
e070ad49f Mauricio Lin          2005-09-03   803  }
e070ad49f Mauricio Lin          2005-09-03   804  
b76437579 Siddhesh Poyarekar    2012-03-21  @805  static int show_pid_smap(struct seq_file *m, void *v)
b76437579 Siddhesh Poyarekar    2012-03-21   806  {
b76437579 Siddhesh Poyarekar    2012-03-21   807  	return show_smap(m, v, 1);
b76437579 Siddhesh Poyarekar    2012-03-21   808  }
b76437579 Siddhesh Poyarekar    2012-03-21   809  
b76437579 Siddhesh Poyarekar    2012-03-21  @810  static int show_tid_smap(struct seq_file *m, void *v)
b76437579 Siddhesh Poyarekar    2012-03-21   811  {
b76437579 Siddhesh Poyarekar    2012-03-21   812  	return show_smap(m, v, 0);
b76437579 Siddhesh Poyarekar    2012-03-21   813  }
b76437579 Siddhesh Poyarekar    2012-03-21   814  
03a44825b Jan Engelhardt        2008-02-08   815  static const struct seq_operations proc_pid_smaps_op = {
a6198797c Matt Mackall          2008-02-04   816  	.start	= m_start,
a6198797c Matt Mackall          2008-02-04   817  	.next	= m_next,
a6198797c Matt Mackall          2008-02-04   818  	.stop	= m_stop,
b76437579 Siddhesh Poyarekar    2012-03-21   819  	.show	= show_pid_smap
a6198797c Matt Mackall          2008-02-04   820  };
a6198797c Matt Mackall          2008-02-04   821  
b76437579 Siddhesh Poyarekar    2012-03-21   822  static const struct seq_operations proc_tid_smaps_op = {
b76437579 Siddhesh Poyarekar    2012-03-21   823  	.start	= m_start,
b76437579 Siddhesh Poyarekar    2012-03-21  @824  	.next	= m_next,
b76437579 Siddhesh Poyarekar    2012-03-21  @825  	.stop	= m_stop,
b76437579 Siddhesh Poyarekar    2012-03-21  @826  	.show	= show_tid_smap
b76437579 Siddhesh Poyarekar    2012-03-21   827  };
b76437579 Siddhesh Poyarekar    2012-03-21   828  
b76437579 Siddhesh Poyarekar    2012-03-21  @829  static int pid_smaps_open(struct inode *inode, struct file *file)
a6198797c Matt Mackall          2008-02-04   830  {
a6198797c Matt Mackall          2008-02-04   831  	return do_maps_open(inode, file, &proc_pid_smaps_op);
a6198797c Matt Mackall          2008-02-04   832  }
a6198797c Matt Mackall          2008-02-04   833  
b76437579 Siddhesh Poyarekar    2012-03-21  @834  static int tid_smaps_open(struct inode *inode, struct file *file)
b76437579 Siddhesh Poyarekar    2012-03-21   835  {
b76437579 Siddhesh Poyarekar    2012-03-21   836  	return do_maps_open(inode, file, &proc_tid_smaps_op);
b76437579 Siddhesh Poyarekar    2012-03-21   837  }
b76437579 Siddhesh Poyarekar    2012-03-21   838  
b76437579 Siddhesh Poyarekar    2012-03-21  @839  const struct file_operations proc_pid_smaps_operations = {
b76437579 Siddhesh Poyarekar    2012-03-21   840  	.open		= pid_smaps_open,
b76437579 Siddhesh Poyarekar    2012-03-21   841  	.read		= seq_read,
b76437579 Siddhesh Poyarekar    2012-03-21  @842  	.llseek		= seq_lseek,
29a40ace8 Oleg Nesterov         2014-10-09  @843  	.release	= proc_map_release,
b76437579 Siddhesh Poyarekar    2012-03-21   844  };
b76437579 Siddhesh Poyarekar    2012-03-21   845  
b76437579 Siddhesh Poyarekar    2012-03-21  @846  const struct file_operations proc_tid_smaps_operations = {
b76437579 Siddhesh Poyarekar    2012-03-21   847  	.open		= tid_smaps_open,
a6198797c Matt Mackall          2008-02-04   848  	.read		= seq_read,
a6198797c Matt Mackall          2008-02-04  @849  	.llseek		= seq_lseek,
29a40ace8 Oleg Nesterov         2014-10-09  @850  	.release	= proc_map_release,
a6198797c Matt Mackall          2008-02-04   851  };
a6198797c Matt Mackall          2008-02-04   852  
040fa0207 Pavel Emelyanov       2013-07-03   853  enum clear_refs_types {
040fa0207 Pavel Emelyanov       2013-07-03   854  	CLEAR_REFS_ALL = 1,
040fa0207 Pavel Emelyanov       2013-07-03   855  	CLEAR_REFS_ANON,
040fa0207 Pavel Emelyanov       2013-07-03   856  	CLEAR_REFS_MAPPED,
0f8975ec4 Pavel Emelyanov       2013-07-03   857  	CLEAR_REFS_SOFT_DIRTY,
695f05593 Petr Cermak           2015-02-12   858  	CLEAR_REFS_MM_HIWATER_RSS,
040fa0207 Pavel Emelyanov       2013-07-03   859  	CLEAR_REFS_LAST,
040fa0207 Pavel Emelyanov       2013-07-03   860  };
040fa0207 Pavel Emelyanov       2013-07-03   861  
af9de7eb1 Pavel Emelyanov       2013-07-03   862  struct clear_refs_private {
0f8975ec4 Pavel Emelyanov       2013-07-03   863  	enum clear_refs_types type;
af9de7eb1 Pavel Emelyanov       2013-07-03   864  };
af9de7eb1 Pavel Emelyanov       2013-07-03   865  
7d5b3bfaa Kirill A. Shutemov    2015-02-11   866  #ifdef CONFIG_MEM_SOFT_DIRTY
0f8975ec4 Pavel Emelyanov       2013-07-03   867  static inline void clear_soft_dirty(struct vm_area_struct *vma,
0f8975ec4 Pavel Emelyanov       2013-07-03   868  		unsigned long addr, pte_t *pte)
0f8975ec4 Pavel Emelyanov       2013-07-03   869  {
0f8975ec4 Pavel Emelyanov       2013-07-03   870  	/*
0f8975ec4 Pavel Emelyanov       2013-07-03   871  	 * The soft-dirty tracker uses #PF-s to catch writes
0f8975ec4 Pavel Emelyanov       2013-07-03   872  	 * to pages, so write-protect the pte as well. See the
0f8975ec4 Pavel Emelyanov       2013-07-03   873  	 * Documentation/vm/soft-dirty.txt for full description
0f8975ec4 Pavel Emelyanov       2013-07-03   874  	 * of how soft-dirty works.
0f8975ec4 Pavel Emelyanov       2013-07-03   875  	 */
0f8975ec4 Pavel Emelyanov       2013-07-03   876  	pte_t ptent = *pte;
179ef71cb Cyrill Gorcunov       2013-08-13   877  
179ef71cb Cyrill Gorcunov       2013-08-13   878  	if (pte_present(ptent)) {
326c2597a Laurent Dufour        2015-11-05   879  		ptent = ptep_modify_prot_start(vma->vm_mm, addr, pte);
0f8975ec4 Pavel Emelyanov       2013-07-03   880  		ptent = pte_wrprotect(ptent);
a7b761749 Martin Schwidefsky    2015-04-22   881  		ptent = pte_clear_soft_dirty(ptent);
326c2597a Laurent Dufour        2015-11-05   882  		ptep_modify_prot_commit(vma->vm_mm, addr, pte, ptent);
179ef71cb Cyrill Gorcunov       2013-08-13   883  	} else if (is_swap_pte(ptent)) {
179ef71cb Cyrill Gorcunov       2013-08-13   884  		ptent = pte_swp_clear_soft_dirty(ptent);
0f8975ec4 Pavel Emelyanov       2013-07-03   885  		set_pte_at(vma->vm_mm, addr, pte, ptent);
0f8975ec4 Pavel Emelyanov       2013-07-03   886  	}
326c2597a Laurent Dufour        2015-11-05   887  }
5d3875a01 Laurent Dufour        2015-11-05   888  #else
5d3875a01 Laurent Dufour        2015-11-05  @889  static inline void clear_soft_dirty(struct vm_area_struct *vma,
5d3875a01 Laurent Dufour        2015-11-05   890  		unsigned long addr, pte_t *pte)
5d3875a01 Laurent Dufour        2015-11-05   891  {
5d3875a01 Laurent Dufour        2015-11-05   892  }
5d3875a01 Laurent Dufour        2015-11-05   893  #endif
0f8975ec4 Pavel Emelyanov       2013-07-03   894  
5d3875a01 Laurent Dufour        2015-11-05   895  #if defined(CONFIG_MEM_SOFT_DIRTY) && defined(CONFIG_TRANSPARENT_HUGEPAGE)
7d5b3bfaa Kirill A. Shutemov    2015-02-11   896  static inline void clear_soft_dirty_pmd(struct vm_area_struct *vma,
7d5b3bfaa Kirill A. Shutemov    2015-02-11   897  		unsigned long addr, pmd_t *pmdp)
7d5b3bfaa Kirill A. Shutemov    2015-02-11   898  {
326c2597a Laurent Dufour        2015-11-05   899  	pmd_t pmd = pmdp_huge_get_and_clear(vma->vm_mm, addr, pmdp);
7d5b3bfaa Kirill A. Shutemov    2015-02-11   900  
7d5b3bfaa Kirill A. Shutemov    2015-02-11   901  	pmd = pmd_wrprotect(pmd);
a7b761749 Martin Schwidefsky    2015-04-22   902  	pmd = pmd_clear_soft_dirty(pmd);
7d5b3bfaa Kirill A. Shutemov    2015-02-11   903  
7d5b3bfaa Kirill A. Shutemov    2015-02-11   904  	set_pmd_at(vma->vm_mm, addr, pmdp, pmd);
7d5b3bfaa Kirill A. Shutemov    2015-02-11   905  }
7d5b3bfaa Kirill A. Shutemov    2015-02-11   906  #else
7d5b3bfaa Kirill A. Shutemov    2015-02-11  @907  static inline void clear_soft_dirty_pmd(struct vm_area_struct *vma,
7d5b3bfaa Kirill A. Shutemov    2015-02-11   908  		unsigned long addr, pmd_t *pmdp)
7d5b3bfaa Kirill A. Shutemov    2015-02-11   909  {
7d5b3bfaa Kirill A. Shutemov    2015-02-11   910  }
7d5b3bfaa Kirill A. Shutemov    2015-02-11   911  #endif
7d5b3bfaa Kirill A. Shutemov    2015-02-11   912  
a6198797c Matt Mackall          2008-02-04  @913  static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
2165009bd Dave Hansen           2008-06-12   914  				unsigned long end, struct mm_walk *walk)
a6198797c Matt Mackall          2008-02-04   915  {
af9de7eb1 Pavel Emelyanov       2013-07-03   916  	struct clear_refs_private *cp = walk->private;
5c64f52ac Naoya Horiguchi       2015-02-11   917  	struct vm_area_struct *vma = walk->vma;
a6198797c Matt Mackall          2008-02-04   918  	pte_t *pte, ptent;
a6198797c Matt Mackall          2008-02-04   919  	spinlock_t *ptl;
a6198797c Matt Mackall          2008-02-04   920  	struct page *page;
a6198797c Matt Mackall          2008-02-04   921  
b6ec57f4b Kirill A. Shutemov    2016-01-21   922  	ptl = pmd_trans_huge_lock(pmd, vma);
b6ec57f4b Kirill A. Shutemov    2016-01-21   923  	if (ptl) {
7d5b3bfaa Kirill A. Shutemov    2015-02-11   924  		if (cp->type == CLEAR_REFS_SOFT_DIRTY) {
7d5b3bfaa Kirill A. Shutemov    2015-02-11   925  			clear_soft_dirty_pmd(vma, addr, pmd);
7d5b3bfaa Kirill A. Shutemov    2015-02-11   926  			goto out;
7d5b3bfaa Kirill A. Shutemov    2015-02-11   927  		}
7d5b3bfaa Kirill A. Shutemov    2015-02-11   928  
7d5b3bfaa Kirill A. Shutemov    2015-02-11   929  		page = pmd_page(*pmd);
7d5b3bfaa Kirill A. Shutemov    2015-02-11   930  
7d5b3bfaa Kirill A. Shutemov    2015-02-11   931  		/* Clear accessed and referenced bits. */
7d5b3bfaa Kirill A. Shutemov    2015-02-11   932  		pmdp_test_and_clear_young(vma, addr, pmd);
33c3fc71c Vladimir Davydov      2015-09-09  @933  		test_and_clear_page_young(page);
7d5b3bfaa Kirill A. Shutemov    2015-02-11   934  		ClearPageReferenced(page);
7d5b3bfaa Kirill A. Shutemov    2015-02-11   935  out:
7d5b3bfaa Kirill A. Shutemov    2015-02-11   936  		spin_unlock(ptl);
7d5b3bfaa Kirill A. Shutemov    2015-02-11   937  		return 0;
7d5b3bfaa Kirill A. Shutemov    2015-02-11   938  	}
7d5b3bfaa Kirill A. Shutemov    2015-02-11   939  
1a5a9906d Andrea Arcangeli      2012-03-21   940  	if (pmd_trans_unstable(pmd))
1a5a9906d Andrea Arcangeli      2012-03-21   941  		return 0;
033193275 Dave Hansen           2011-03-22   942  
a6198797c Matt Mackall          2008-02-04   943  	pte = pte_offset_map_lock(vma->vm_mm, pmd, addr, &ptl);
a6198797c Matt Mackall          2008-02-04   944  	for (; addr != end; pte++, addr += PAGE_SIZE) {
a6198797c Matt Mackall          2008-02-04   945  		ptent = *pte;
a6198797c Matt Mackall          2008-02-04   946  
0f8975ec4 Pavel Emelyanov       2013-07-03   947  		if (cp->type == CLEAR_REFS_SOFT_DIRTY) {
0f8975ec4 Pavel Emelyanov       2013-07-03   948  			clear_soft_dirty(vma, addr, pte);
0f8975ec4 Pavel Emelyanov       2013-07-03   949  			continue;
0f8975ec4 Pavel Emelyanov       2013-07-03   950  		}
0f8975ec4 Pavel Emelyanov       2013-07-03   951  
179ef71cb Cyrill Gorcunov       2013-08-13   952  		if (!pte_present(ptent))
179ef71cb Cyrill Gorcunov       2013-08-13   953  			continue;
179ef71cb Cyrill Gorcunov       2013-08-13   954  
a6198797c Matt Mackall          2008-02-04   955  		page = vm_normal_page(vma, addr, ptent);
a6198797c Matt Mackall          2008-02-04   956  		if (!page)
a6198797c Matt Mackall          2008-02-04   957  			continue;
a6198797c Matt Mackall          2008-02-04   958  
a6198797c Matt Mackall          2008-02-04   959  		/* Clear accessed and referenced bits. */
a6198797c Matt Mackall          2008-02-04   960  		ptep_test_and_clear_young(vma, addr, pte);
33c3fc71c Vladimir Davydov      2015-09-09   961  		test_and_clear_page_young(page);
a6198797c Matt Mackall          2008-02-04   962  		ClearPageReferenced(page);
a6198797c Matt Mackall          2008-02-04   963  	}
a6198797c Matt Mackall          2008-02-04   964  	pte_unmap_unlock(pte - 1, ptl);
a6198797c Matt Mackall          2008-02-04   965  	cond_resched();
a6198797c Matt Mackall          2008-02-04   966  	return 0;
a6198797c Matt Mackall          2008-02-04   967  }
a6198797c Matt Mackall          2008-02-04   968  
5c64f52ac Naoya Horiguchi       2015-02-11  @969  static int clear_refs_test_walk(unsigned long start, unsigned long end,
5c64f52ac Naoya Horiguchi       2015-02-11   970  				struct mm_walk *walk)
5c64f52ac Naoya Horiguchi       2015-02-11   971  {
5c64f52ac Naoya Horiguchi       2015-02-11   972  	struct clear_refs_private *cp = walk->private;
5c64f52ac Naoya Horiguchi       2015-02-11   973  	struct vm_area_struct *vma = walk->vma;
5c64f52ac Naoya Horiguchi       2015-02-11   974  
48684a65b Naoya Horiguchi       2015-02-11   975  	if (vma->vm_flags & VM_PFNMAP)
48684a65b Naoya Horiguchi       2015-02-11   976  		return 1;
48684a65b Naoya Horiguchi       2015-02-11   977  
5c64f52ac Naoya Horiguchi       2015-02-11   978  	/*
5c64f52ac Naoya Horiguchi       2015-02-11   979  	 * Writing 1 to /proc/pid/clear_refs affects all pages.
5c64f52ac Naoya Horiguchi       2015-02-11   980  	 * Writing 2 to /proc/pid/clear_refs only affects anonymous pages.
5c64f52ac Naoya Horiguchi       2015-02-11   981  	 * Writing 3 to /proc/pid/clear_refs only affects file mapped pages.
5c64f52ac Naoya Horiguchi       2015-02-11   982  	 * Writing 4 to /proc/pid/clear_refs affects all pages.
5c64f52ac Naoya Horiguchi       2015-02-11   983  	 */
5c64f52ac Naoya Horiguchi       2015-02-11   984  	if (cp->type == CLEAR_REFS_ANON && vma->vm_file)
5c64f52ac Naoya Horiguchi       2015-02-11   985  		return 1;
5c64f52ac Naoya Horiguchi       2015-02-11   986  	if (cp->type == CLEAR_REFS_MAPPED && !vma->vm_file)
5c64f52ac Naoya Horiguchi       2015-02-11   987  		return 1;
5c64f52ac Naoya Horiguchi       2015-02-11   988  	return 0;
5c64f52ac Naoya Horiguchi       2015-02-11   989  }
5c64f52ac Naoya Horiguchi       2015-02-11   990  
f248dcb34 Matt Mackall          2008-02-04  @991  static ssize_t clear_refs_write(struct file *file, const char __user *buf,
f248dcb34 Matt Mackall          2008-02-04   992  				size_t count, loff_t *ppos)
b813e931b David Rientjes        2007-05-06   993  {
f248dcb34 Matt Mackall          2008-02-04   994  	struct task_struct *task;
fb92a4b06 Vincent Li            2009-09-22   995  	char buffer[PROC_NUMBUF];
f248dcb34 Matt Mackall          2008-02-04   996  	struct mm_struct *mm;
b813e931b David Rientjes        2007-05-06   997  	struct vm_area_struct *vma;
040fa0207 Pavel Emelyanov       2013-07-03   998  	enum clear_refs_types type;
040fa0207 Pavel Emelyanov       2013-07-03   999  	int itype;
0a8cb8e34 Alexey Dobriyan       2011-05-26  1000  	int rv;
b813e931b David Rientjes        2007-05-06  1001  
f248dcb34 Matt Mackall          2008-02-04  1002  	memset(buffer, 0, sizeof(buffer));
f248dcb34 Matt Mackall          2008-02-04  1003  	if (count > sizeof(buffer) - 1)
f248dcb34 Matt Mackall          2008-02-04  1004  		count = sizeof(buffer) - 1;
f248dcb34 Matt Mackall          2008-02-04  1005  	if (copy_from_user(buffer, buf, count))
f248dcb34 Matt Mackall          2008-02-04  1006  		return -EFAULT;
040fa0207 Pavel Emelyanov       2013-07-03  1007  	rv = kstrtoint(strstrip(buffer), 10, &itype);
0a8cb8e34 Alexey Dobriyan       2011-05-26  1008  	if (rv < 0)
0a8cb8e34 Alexey Dobriyan       2011-05-26  1009  		return rv;
040fa0207 Pavel Emelyanov       2013-07-03  1010  	type = (enum clear_refs_types)itype;
040fa0207 Pavel Emelyanov       2013-07-03  1011  	if (type < CLEAR_REFS_ALL || type >= CLEAR_REFS_LAST)
f248dcb34 Matt Mackall          2008-02-04  1012  		return -EINVAL;
541c237c0 Pavel Emelyanov       2013-07-03  1013  
496ad9aa8 Al Viro               2013-01-23 @1014  	task = get_proc_task(file_inode(file));
f248dcb34 Matt Mackall          2008-02-04  1015  	if (!task)
f248dcb34 Matt Mackall          2008-02-04  1016  		return -ESRCH;
f248dcb34 Matt Mackall          2008-02-04 @1017  	mm = get_task_mm(task);
f248dcb34 Matt Mackall          2008-02-04  1018  	if (mm) {
af9de7eb1 Pavel Emelyanov       2013-07-03  1019  		struct clear_refs_private cp = {
0f8975ec4 Pavel Emelyanov       2013-07-03  1020  			.type = type,
af9de7eb1 Pavel Emelyanov       2013-07-03  1021  		};
20cbc9726 Andrew Morton         2008-07-05  1022  		struct mm_walk clear_refs_walk = {
20cbc9726 Andrew Morton         2008-07-05  1023  			.pmd_entry = clear_refs_pte_range,
5c64f52ac Naoya Horiguchi       2015-02-11  1024  			.test_walk = clear_refs_test_walk,
20cbc9726 Andrew Morton         2008-07-05  1025  			.mm = mm,
af9de7eb1 Pavel Emelyanov       2013-07-03  1026  			.private = &cp,
20cbc9726 Andrew Morton         2008-07-05  1027  		};
695f05593 Petr Cermak           2015-02-12  1028  
695f05593 Petr Cermak           2015-02-12  1029  		if (type == CLEAR_REFS_MM_HIWATER_RSS) {
527157715 Michal Hocko          2016-05-24  1030  			if (down_write_killable(&mm->mmap_sem)) {
527157715 Michal Hocko          2016-05-24  1031  				count = -EINTR;
527157715 Michal Hocko          2016-05-24  1032  				goto out_mm;
527157715 Michal Hocko          2016-05-24  1033  			}
527157715 Michal Hocko          2016-05-24  1034  
695f05593 Petr Cermak           2015-02-12  1035  			/*
695f05593 Petr Cermak           2015-02-12  1036  			 * Writing 5 to /proc/pid/clear_refs resets the peak
695f05593 Petr Cermak           2015-02-12  1037  			 * resident set size to this mm's current rss value.
695f05593 Petr Cermak           2015-02-12  1038  			 */
695f05593 Petr Cermak           2015-02-12  1039  			reset_mm_hiwater_rss(mm);
695f05593 Petr Cermak           2015-02-12  1040  			up_write(&mm->mmap_sem);
695f05593 Petr Cermak           2015-02-12  1041  			goto out_mm;
695f05593 Petr Cermak           2015-02-12  1042  		}
695f05593 Petr Cermak           2015-02-12  1043  
b813e931b David Rientjes        2007-05-06  1044  		down_read(&mm->mmap_sem);
64e455079 Peter Feiner          2014-10-13  1045  		if (type == CLEAR_REFS_SOFT_DIRTY) {
64e455079 Peter Feiner          2014-10-13  1046  			for (vma = mm->mmap; vma; vma = vma->vm_next) {
64e455079 Peter Feiner          2014-10-13  1047  				if (!(vma->vm_flags & VM_SOFTDIRTY))
64e455079 Peter Feiner          2014-10-13  1048  					continue;
64e455079 Peter Feiner          2014-10-13  1049  				up_read(&mm->mmap_sem);
527157715 Michal Hocko          2016-05-24  1050  				if (down_write_killable(&mm->mmap_sem)) {
527157715 Michal Hocko          2016-05-24  1051  					count = -EINTR;
527157715 Michal Hocko          2016-05-24  1052  					goto out_mm;
527157715 Michal Hocko          2016-05-24  1053  				}
64e455079 Peter Feiner          2014-10-13  1054  				for (vma = mm->mmap; vma; vma = vma->vm_next) {
64e455079 Peter Feiner          2014-10-13  1055  					vma->vm_flags &= ~VM_SOFTDIRTY;
64e455079 Peter Feiner          2014-10-13  1056  					vma_set_page_prot(vma);
64e455079 Peter Feiner          2014-10-13  1057  				}
64e455079 Peter Feiner          2014-10-13  1058  				downgrade_write(&mm->mmap_sem);
64e455079 Peter Feiner          2014-10-13  1059  				break;
64e455079 Peter Feiner          2014-10-13  1060  			}
0f8975ec4 Pavel Emelyanov       2013-07-03  1061  			mmu_notifier_invalidate_range_start(mm, 0, -1);
64e455079 Peter Feiner          2014-10-13  1062  		}
5c64f52ac Naoya Horiguchi       2015-02-11  1063  		walk_page_range(0, ~0UL, &clear_refs_walk);
0f8975ec4 Pavel Emelyanov       2013-07-03  1064  		if (type == CLEAR_REFS_SOFT_DIRTY)
0f8975ec4 Pavel Emelyanov       2013-07-03  1065  			mmu_notifier_invalidate_range_end(mm, 0, -1);
b813e931b David Rientjes        2007-05-06  1066  		flush_tlb_mm(mm);
b813e931b David Rientjes        2007-05-06  1067  		up_read(&mm->mmap_sem);
695f05593 Petr Cermak           2015-02-12  1068  out_mm:
f248dcb34 Matt Mackall          2008-02-04  1069  		mmput(mm);
b813e931b David Rientjes        2007-05-06  1070  	}
f248dcb34 Matt Mackall          2008-02-04 @1071  	put_task_struct(task);
fb92a4b06 Vincent Li            2009-09-22  1072  
fb92a4b06 Vincent Li            2009-09-22  1073  	return count;
f248dcb34 Matt Mackall          2008-02-04  1074  }
f248dcb34 Matt Mackall          2008-02-04  1075  
f248dcb34 Matt Mackall          2008-02-04 @1076  const struct file_operations proc_clear_refs_operations = {
f248dcb34 Matt Mackall          2008-02-04 @1077  	.write		= clear_refs_write,
6038f373a Arnd Bergmann         2010-08-15 @1078  	.llseek		= noop_llseek,
f248dcb34 Matt Mackall          2008-02-04  1079  };
b813e931b David Rientjes        2007-05-06  1080  
092b50bac Naoya Horiguchi       2012-03-21  1081  typedef struct {
092b50bac Naoya Horiguchi       2012-03-21  1082  	u64 pme;
092b50bac Naoya Horiguchi       2012-03-21  1083  } pagemap_entry_t;
092b50bac Naoya Horiguchi       2012-03-21  1084  
85863e475 Matt Mackall          2008-02-04  1085  struct pagemapread {
8c8296223 yonghua zheng         2013-08-13  1086  	int pos, len;		/* units: PM_ENTRY_BYTES, not bytes */
092b50bac Naoya Horiguchi       2012-03-21  1087  	pagemap_entry_t *buffer;
1c90308e7 Konstantin Khlebnikov 2015-09-08  1088  	bool show_pfn;
85863e475 Matt Mackall          2008-02-04  1089  };
85863e475 Matt Mackall          2008-02-04  1090  
5aaabe831 Naoya Horiguchi       2012-03-21  1091  #define PAGEMAP_WALK_SIZE	(PMD_SIZE)
5aaabe831 Naoya Horiguchi       2012-03-21  1092  #define PAGEMAP_WALK_MASK	(PMD_MASK)
5aaabe831 Naoya Horiguchi       2012-03-21  1093  
8c8296223 yonghua zheng         2013-08-13  1094  #define PM_ENTRY_BYTES		sizeof(pagemap_entry_t)
deb945441 Konstantin Khlebnikov 2015-09-08  1095  #define PM_PFRAME_BITS		55
deb945441 Konstantin Khlebnikov 2015-09-08  1096  #define PM_PFRAME_MASK		GENMASK_ULL(PM_PFRAME_BITS - 1, 0)
deb945441 Konstantin Khlebnikov 2015-09-08  1097  #define PM_SOFT_DIRTY		BIT_ULL(55)
77bb499bb Konstantin Khlebnikov 2015-09-08  1098  #define PM_MMAP_EXCLUSIVE	BIT_ULL(56)
deb945441 Konstantin Khlebnikov 2015-09-08  1099  #define PM_FILE			BIT_ULL(61)
deb945441 Konstantin Khlebnikov 2015-09-08  1100  #define PM_SWAP			BIT_ULL(62)
deb945441 Konstantin Khlebnikov 2015-09-08  1101  #define PM_PRESENT		BIT_ULL(63)
deb945441 Konstantin Khlebnikov 2015-09-08  1102  
85863e475 Matt Mackall          2008-02-04  1103  #define PM_END_OF_BUFFER    1
85863e475 Matt Mackall          2008-02-04  1104  
deb945441 Konstantin Khlebnikov 2015-09-08 @1105  static inline pagemap_entry_t make_pme(u64 frame, u64 flags)
092b50bac Naoya Horiguchi       2012-03-21  1106  {
deb945441 Konstantin Khlebnikov 2015-09-08  1107  	return (pagemap_entry_t) { .pme = (frame & PM_PFRAME_MASK) | flags };
092b50bac Naoya Horiguchi       2012-03-21  1108  }
092b50bac Naoya Horiguchi       2012-03-21  1109  
092b50bac Naoya Horiguchi       2012-03-21 @1110  static int add_to_pagemap(unsigned long addr, pagemap_entry_t *pme,
85863e475 Matt Mackall          2008-02-04  1111  			  struct pagemapread *pm)
85863e475 Matt Mackall          2008-02-04  1112  {
092b50bac Naoya Horiguchi       2012-03-21  1113  	pm->buffer[pm->pos++] = *pme;
d82ef020c KAMEZAWA Hiroyuki     2010-04-02  1114  	if (pm->pos >= pm->len)
aae8679b0 Thomas Tuttle         2008-06-05  1115  		return PM_END_OF_BUFFER;
85863e475 Matt Mackall          2008-02-04  1116  	return 0;
85863e475 Matt Mackall          2008-02-04  1117  }
85863e475 Matt Mackall          2008-02-04  1118  
85863e475 Matt Mackall          2008-02-04 @1119  static int pagemap_pte_hole(unsigned long start, unsigned long end,
2165009bd Dave Hansen           2008-06-12  1120  				struct mm_walk *walk)
85863e475 Matt Mackall          2008-02-04  1121  {
2165009bd Dave Hansen           2008-06-12  1122  	struct pagemapread *pm = walk->private;

:::::: The code at line 933 was first introduced by commit
:::::: 33c3fc71c8cfa3cc3a98beaa901c069c177dc295 mm: introduce idle page tracking

:::::: TO: Vladimir Davydov <vdavydov@parallels.com>
:::::: CC: Linus Torvalds <torvalds@linux-foundation.org>

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--17pEHd4RhPHOinZp
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=".config.gz"
Content-Transfer-Encoding: base64

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
metG9/nSM35rdtO5KGSpNr0kfTgQsVRsBYJnIE9RjuoAtNyhJ4E9C/SXuAw3oGTSIvc2XkzG
lOiFHEbzBELAWLWzpUExHg33OmCiJkQErbT50zO7mvn1XLicS0BXVb6JNcIefqPBWYwNDhce
AVON+ALmjRaV5l3AwdViprNdhKbAOveNT8Y3SgcuGAatKyhijuUA9+Cb9cwbyq8WK/Tl7Ruc
05YRezGe2dcVwfPhhUfdVp39XxG9Eh9Y1pbI69OzDP+LM1XCzZ+L5d6WM4+P7e073qcJnUFP
byd5lWCdeqocA02y27Tqryj6e6CqKtr3du/UOV9VyOe2NRV+I7mj3jSN0+6kDJxkX9plzwWr
/nK+4rqBmA5ntM8aoMZkPAki9Ju66WTk6UxgOpnQl3yAMC5RptPliF4CHDd244bOjs9Gk9LB
/RG7MBjldD6luAciZhr3w1LW+u+l8eHzsSO4PZ2Nxg4NCpjS1KN8zRCxGHkac5rMdbM/gpYj
umGxg0M/sPYKbpDHj5eXH1bFZFxUIqQ4utHyavPVJoRjoxSBiRGypmbDtUiE4GP1a425SA6v
Dz+6+83/4iVXGFb/LpJEVxi5unN/Ob3/OzyeL+/Hvz70OqJ+uBR+tsLt7vn+fPg9gQcPj4Pk
dHob/Aot/jb4u3vjWXmj2soazpahubGoW1TjKn24cJiwOJZ2im1x2hnM7+Vn2o7bl9VkqhYL
STfezPqtsxIJ01iIwvU2d2XeqFdWkr0IOMpsNAodMK+g4XUWmm1kYIPg24f7b5dn5Zxooe+X
QXl/OQzS0+vxYg7xOppMHFtN4KjLKFQshp7y6o+X4+Px8oOcxHREF9MKt0w10mxDlFoUCWLL
anXPVvFcExLx96jrQQxr+ILhVC+H+/PHuyia/gHfSyyoCRmOIXGm5B7L+SdHSKJpDrlL9yrX
i7MbrOcwG4IIputCKkI7sxSEdWBhd/UQEBXaK0SkB4Fu1vYT2ibth59hVY89h/CbAB8e0gYv
vwirJV3fgaOW2h7besYNe5COR57DdRpxLgsaiGykzAyI2UxVQTbFyC9g9fjDoapSoruEpx8L
qmbmGCaFpChJK9PnytfzuJdFCVKouril7CECcnt4wkojRhW23mQydNyS5QWDUacHroA+jIYm
uleixmM1eoAF1XiiWnk5YK4nuZad5k4lZFAFYCbTsZbPZeotRpo16CbIEucH3UQpyNRz2zsp
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
NDcwvaobM7EYIxjcDjuNG+NsJuJ/HcBj/O+CAQA=

--17pEHd4RhPHOinZp--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
