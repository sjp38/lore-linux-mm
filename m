Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0CD1C6B0038
	for <linux-mm@kvack.org>; Thu, 18 Dec 2014 20:49:32 -0500 (EST)
Received: by mail-ob0-f169.google.com with SMTP id vb8so9449915obc.0
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 17:49:31 -0800 (PST)
Received: from mail-ob0-x233.google.com (mail-ob0-x233.google.com. [2607:f8b0:4003:c01::233])
        by mx.google.com with ESMTPS id h18si5255230oem.43.2014.12.18.17.49.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 18 Dec 2014 17:49:30 -0800 (PST)
Received: by mail-ob0-f179.google.com with SMTP id va2so9364880obc.10
        for <linux-mm@kvack.org>; Thu, 18 Dec 2014 17:49:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141219013016.GA12973@bbox>
References: <1418478314-17731-1-git-send-email-opensource.ganesh@gmail.com>
	<20141216024509.GB17665@blaptop>
	<CADAEsF9AVzh+7cUFthBx67Q1s43vNj7j9158w3DZpt4pSzLijQ@mail.gmail.com>
	<20141218234455.GA1538@bbox>
	<CADAEsF8c46-2yq37ahQ0VaAQFxG-LUmvieUf_koy=HqyonjwpQ@mail.gmail.com>
	<20141219013016.GA12973@bbox>
Date: Fri, 19 Dec 2014 09:49:29 +0800
Message-ID: <CADAEsF8H_kT_-TEH+qUK44DVK6FT0TwD6Eby1BzK-b2vo6AggA@mail.gmail.com>
Subject: Re: [PATCH 2/2] mm/zsmalloc: add statistics support
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

2014-12-19 9:30 GMT+08:00 Minchan Kim <minchan@kernel.org>:
> On Fri, Dec 19, 2014 at 09:21:52AM +0800, Ganesh Mahendran wrote:
>> Hello, Minchan
>>
>> 2014-12-19 7:44 GMT+08:00 Minchan Kim <minchan@kernel.org>:
>> > Hello Ganesh,
>> >
>> > On Wed, Dec 17, 2014 at 03:05:19PM +0800, Ganesh Mahendran wrote:
>> >> Hello, Minchan
>> >>
>> >> Thanks for your review.
>> >>
>> >> 2014-12-16 10:45 GMT+08:00 Minchan Kim <minchan@kernel.org>:
>> >> > On Sat, Dec 13, 2014 at 09:45:14PM +0800, Ganesh Mahendran wrote:
>> >> >> As a ram based memory allocator, keep the fragmentation in a low level
>> >> >
>> >> > Just say, zsmalloc.
>> >>
>> >> Ok.
>> >>
>> >> >
>> >> >> is our target. But now we still need to add the debug code in zsmalloc
>> >> >> to get the quantitative data.
>> >> >>
>> >> >> After the RFC patch [1], Minchan Kim gave some suggestions.
>> >> >>   [1] https://patchwork.kernel.org/patch/5469301/
>> >> >>
>> >> >> This patch adds a new configuration CONFIG_ZSMALLOC_STAT to enable the statistics
>> >> >> collection for developers. Currently only the objects information in each class
>> >> >> are collected. User can get the information via debugfs. For example:
>> >> >>
>> >> >> After I copy file jdk-8u25-linux-x64.tar.gz to zram with ext4 filesystem.
>> >> >>  class  size obj_allocated   obj_used pages_used
>> >> >>      0    32             0          0          0
>> >> >>      1    48           256         12          3
>> >> >>      2    64            64         14          1
>> >> >>      3    80            51          7          1
>> >> >>      4    96           128          5          3
>> >> >>      5   112            73          5          2
>> >> >>      6   128            32          4          1
>> >> >>      7   144             0          0          0
>> >> >>      8   160             0          0          0
>> >> >>      9   176             0          0          0
>> >> >>     10   192             0          0          0
>> >> >>     11   208             0          0          0
>> >> >>     12   224             0          0          0
>> >> >>     13   240             0          0          0
>> >> >>     14   256            16          1          1
>> >> >>     15   272            15          9          1
>> >> >>     16   288             0          0          0
>> >> >>     17   304             0          0          0
>> >> >>     18   320             0          0          0
>> >> >>     19   336             0          0          0
>> >> >>     20   352             0          0          0
>> >> >>     21   368             0          0          0
>> >> >>     22   384             0          0          0
>> >> >>     23   400             0          0          0
>> >> >>     24   416             0          0          0
>> >> >>     25   432             0          0          0
>> >> >>     26   448             0          0          0
>> >> >>     27   464             0          0          0
>> >> >>     28   480             0          0          0
>> >> >>     29   496            33          1          4
>> >> >>     30   512             0          0          0
>> >> >>     31   528             0          0          0
>> >> >>     32   544             0          0          0
>> >> >>     33   560             0          0          0
>> >> >>     34   576             0          0          0
>> >> >>     35   592             0          0          0
>> >> >>     36   608             0          0          0
>> >> >>     37   624             0          0          0
>> >> >>     38   640             0          0          0
>> >> >>     40   672             0          0          0
>> >> >>     42   704             0          0          0
>> >> >>     43   720            17          1          3
>> >> >>     44   736             0          0          0
>> >> >>     46   768             0          0          0
>> >> >>     49   816             0          0          0
>> >> >>     51   848             0          0          0
>> >> >>     52   864            14          1          3
>> >> >>     54   896             0          0          0
>> >> >>     57   944            13          1          3
>> >> >>     58   960             0          0          0
>> >> >>     62  1024             4          1          1
>> >> >>     66  1088            15          2          4
>> >> >>     67  1104             0          0          0
>> >> >>     71  1168             0          0          0
>> >> >>     74  1216             0          0          0
>> >> >>     76  1248             0          0          0
>> >> >>     83  1360             3          1          1
>> >> >>     91  1488            11          1          4
>> >> >>     94  1536             0          0          0
>> >> >>    100  1632             5          1          2
>> >> >>    107  1744             0          0          0
>> >> >>    111  1808             9          1          4
>> >> >>    126  2048             4          4          2
>> >> >>    144  2336             7          3          4
>> >> >>    151  2448             0          0          0
>> >> >>    168  2720            15         15         10
>> >> >>    190  3072            28         27         21
>> >> >>    202  3264             0          0          0
>> >> >>    254  4096         36209      36209      36209
>> >> >>
>> >> >>  Total               37022      36326      36288
>> >> >>
>> >> >> We can see the overall fragentation is:
>> >> >>     (37022 - 36326) / 37022 = 1.87%
>> >> >>
>> >> >> Also from the statistics we know why we got so low fragmentation:
>> >> >> Most of the objects is in class 254 with size 4096 Bytes. The pages in
>> >> >> zspage is 1. And there is only one object in a page. So, No fragmentation
>> >> >> will be produced.
>> >> >>
>> >> >> Also we can collect other information and show it to user in the future.
>> >> >
>> >> > So, could you make zs
>> >> Ok
>> >> >>
>> >> >> Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
>> >> >> Suggested-by: Minchan Kim <minchan@kernel.org>
>> >> >> ---
>> >> >>  mm/Kconfig    |   10 ++++
>> >> >>  mm/zsmalloc.c |  164 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>> >> >>  2 files changed, 174 insertions(+)
>> >> >>
>> >> >> diff --git a/mm/Kconfig b/mm/Kconfig
>> >> >> index 1d1ae6b..95c5728 100644
>> >> >> --- a/mm/Kconfig
>> >> >> +++ b/mm/Kconfig
>> >> >> @@ -601,6 +601,16 @@ config PGTABLE_MAPPING
>> >> >>         You can check speed with zsmalloc benchmark:
>> >> >>         https://github.com/spartacus06/zsmapbench
>> >> >>
>> >> >> +config ZSMALLOC_STAT
>> >> >> +     bool "Export zsmalloc statistics"
>> >> >> +     depends on ZSMALLOC
>> >> >> +     select DEBUG_FS
>> >> >> +     help
>> >> >> +       This option enables code in the zsmalloc to collect various
>> >> >> +       statistics about whats happening in zsmalloc and exports that
>> >> >> +       information to userspace via debugfs.
>> >> >> +       If unsure, say N.
>> >> >> +
>> >> >>  config GENERIC_EARLY_IOREMAP
>> >> >>       bool
>> >> >>
>> >> >> diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
>> >> >> index b724039..a8d0020 100644
>> >> >> --- a/mm/zsmalloc.c
>> >> >> +++ b/mm/zsmalloc.c
>> >> >> @@ -168,6 +168,8 @@ enum fullness_group {
>> >> >>       ZS_FULL
>> >> >>  };
>> >> >>
>> >> >> +static int zs_pool_num;
>> >> >
>> >> > What's this? What protects the race?
>> >> It is the pool index. Yes, there is problem here.
>> >> I will change it to atomic and increased every time a new zs pool created.
>> >> And then name the /sys/kernel/debug/pool-x using this index.
>> >>
>> >> static atomic_t zs_pool_index = ATOMIC_INIT(0);
>> >> ...
>> >> pool->index = atomic_inc_return(&zs_pool_index);
>> >>
>> >> > It means description.
>> >> >
>> >> >> +
>> >> >>  /*
>> >> >>   * number of size_classes
>> >> >>   */
>> >> >> @@ -200,6 +202,11 @@ struct size_class {
>> >> >>       /* Number of PAGE_SIZE sized pages to combine to form a 'zspage' */
>> >> >>       int pages_per_zspage;
>> >> >>
>> >> >> +#ifdef CONFIG_ZSMALLOC_STAT
>> >> >> +     unsigned long obj_allocated;
>> >> >> +     unsigned long obj_used;
>> >> >> +#endif
>> >> >
>> >> > I perfer creating new struct.
>> >> >
>> >> > struct zs_size_stat {
>> >> >         unsigend long obj_allocated;
>> >> >         unsignged long obj_used;
>> >> > };
>> >>
>> >> Got it, I will redo this.
>> >>
>> >> >
>> >> >> +
>> >> >>       spinlock_t lock;
>> >> >>
>> >> >>       struct page *fullness_list[_ZS_NR_FULLNESS_GROUPS];
>> >> >> @@ -221,6 +228,10 @@ struct zs_pool {
>> >> >>
>> >> >>       gfp_t flags;    /* allocation flags used when growing pool */
>> >> >>       atomic_long_t pages_allocated;
>> >> >> +
>> >> >> +#ifdef CONFIG_ZSMALLOC_STAT
>> >> >> +     struct dentry *stat_dentry;
>> >> >> +#endif
>> >> >>  };
>> >> >>
>> >> >>  /*
>> >> >> @@ -942,6 +953,132 @@ static bool can_merge(struct size_class *prev, int size, int pages_per_zspage)
>> >> >>       return true;
>> >> >>  }
>> >> >>
>> >> >> +
>> >> >> +#ifdef CONFIG_ZSMALLOC_STAT
>> >> >> +#include <linux/debugfs.h>
>> >> >
>> >> > A question:
>> >> > Why "#include" is here instead of top on the source file?
>> >>
>> >> Yes, the "#include ..." should be on the top of the source file.
>> >> I will modify it.
>> >>
>> >> >
>> >> >> +
>> >> >> +static struct dentry *zs_stat_root;
>> >> >> +
>> >> >> +static int __init zs_stat_init(void)
>> >> >> +{
>> >> >> +     if (!debugfs_initialized())
>> >> >> +             return -ENODEV;
>> >> >
>> >> > Do we need above check?
>> >> Yes, I think we need this check.
>> >> When debugfs module init failed, we should not go ahead here.
>> >>
>> >> >
>> >> > When I read comment of debugfs_create_dir, it says
>> >> > "If debugfs is not enabled in the kernel, the value -%ENODEV will be
>> >> > returned."
>> >>
>> >> This check is not for the situation when the debugfs is not enabled.
>> >> But for if we failed in debugfs_init(), then
>> >> we should not use any API of debugfs.
>> >>
>> >> And I think "-%ENODEV will be returned" means below code in "debugfs.h"
>> >>
>> >> static inline struct dentry *debugfs_create_dir(const char *name,
>> >> struct dentry *parent)
>> >> {
>> >>     return ERR_PTR(-ENODEV);
>> >> }
>> >>
>> >> >
>> >> >> +
>> >> >> +     zs_stat_root = debugfs_create_dir("zsmalloc", NULL);
>> >> >> +     if (!zs_stat_root)
>> >> >> +             return -ENOMEM;
>> >> >
>> >> > On null return of debugfs_create_dir, it means always ENOMEM?
>> >>
>> >> Yes, you are right.  -ENOMEM is not the only reason for the failure.
>> >> But debugfs_create_dir does not bring back the errno.
>> >> And for zsmalloc, we indeed have the permission(-EPERM) to create the entry and
>> >> also we will not create duplicate(-EEXIST) entry in debufs.
>> >>
>> >> So, I think -ENOMEM is suitable.
>> >
>> > It seems you are saying why debugfs_create_dir can fail but zsmalloc will not
>> > fail by such reasons.
>> > I don't know the internal of debugfs_create_dir but description just says
>> > "If an error occurs, %NULL will be returned" but everyone returns ENOMEM
>> > blindly then. Hmm, I don't think it's good but I'm okay too because it's not
>> > our fault and others have been in there. :(
>> >
>> > When I look at zs_init, you don't propagate the error to user. Just missing?
>>
>> As the statistics collection is not essential to user, and I think we
>> do not need to break
>> the zsmalloc module loading when error happens in
>> zs_stat_init()/debugfs_create_dir().
>> So I do not propagate the error to user and just give the message:
>>        pr_warn("zs stat initialization failed\n");
>
> Hmm? So you want to work without stat although user want?

It seems we should allow user to know there is something wrong
happened in module loading.

In the beginning, I just considered that it was only a debug option.
When developers enable
this option in the end-user's machine, It should not affect zsmalloc's
basic function.

> It means every zs_stat_[inc|dec] should check if it was initialized properly?

In zs_stat_[inc|dec], these functions only handle the fields in struct
size_class{}. So we do not need
to check whether it was .initialized properly. But when failed in
zs_stat_init(),  there is
no way to show these statistics to user.

>
>>
>> Thanks.
>>
>> >
>> >>
>> >> >
>> >> >> +
>> >> >> +     return 0;
>> >> >> +}
>> >> >> +
>> >> >> +static void __exit zs_stat_exit(void)
>> >> >> +{
>> >> >> +     debugfs_remove_recursive(zs_stat_root);
>> >> >> +}
>> >> >> +
>> >> >> +static int zs_stats_show(struct seq_file *s, void *v)
>> >> >> +{
>> >> >> +     int i;
>> >> >> +     struct zs_pool *pool = (struct zs_pool *)s->private;
>> >> >> +     struct size_class *class;
>> >> >> +     int objs_per_zspage;
>> >> >> +     unsigned long obj_allocated, obj_used, pages_used;
>> >> >> +     unsigned long total_objs = 0, total_used_objs = 0, total_pages = 0;
>> >> >> +
>> >> >> +     seq_printf(s, " %5s %5s %13s %10s %10s\n", "class", "size",
>> >> >> +                             "obj_allocated", "obj_used", "pages_used");
>> >> >> +
>> >> >> +     for (i = 0; i < zs_size_classes; i++) {
>> >> >> +             class = pool->size_class[i];
>> >> >> +
>> >> >> +             if (class->index != i)
>> >> >> +                     continue;
>> >> >> +
>> >> >> +             spin_lock(&class->lock);
>> >> >> +
>> >> >> +             obj_allocated = class->obj_allocated;
>> >> >> +             obj_used = class->obj_used;
>> >> >> +             objs_per_zspage = get_maxobj_per_zspage(class->size,
>> >> >> +                             class->pages_per_zspage);
>> >> >> +             pages_used = obj_allocated / objs_per_zspage *
>> >> >> +                             class->pages_per_zspage;
>> >> >
>> >> > I think We don't need to protect class->pages_per_zspage with class->lock.
>> >>
>> >> Yes, you are right.
>> >>
>> >> >
>> >> >> +
>> >> >> +             spin_unlock(&class->lock);
>> >> >> +
>> >> >> +             seq_printf(s, " %5u %5u    %10lu %10lu %10lu\n", i, class->size,
>> >> >> +                                     obj_allocated, obj_used, pages_used);
>> >> >> +
>> >> >> +             total_objs += class->obj_allocated;
>> >> >> +             total_used_objs += class->obj_used;
>> >> >
>> >> > You couldn't access class->fields without class lock.
>> >> > Please, assign them into local variable under the lock and sum them without the lock.
>> >>
>> >> Got it. I will redo this.
>> >>
>> >> >
>> >> >> +             total_pages += pages_used;
>> >> >> +     }
>> >> >> +
>> >> >> +     seq_puts(s, "\n");
>> >> >> +     seq_printf(s, " %5s %5s    %10lu %10lu %10lu\n", "Total", "",
>> >> >> +                     total_objs, total_used_objs, total_pages);
>> >> >> +
>> >> >> +     return 0;
>> >> >> +}
>> >> >> +
>> >> >> +static int zs_stats_open(struct inode *inode, struct file *file)
>> >> >> +{
>> >> >> +     return single_open(file, zs_stats_show, inode->i_private);
>> >> >> +}
>> >> >> +
>> >> >> +static const struct file_operations zs_stats_operations = {
>> >> >> +     .open           = zs_stats_open,
>> >> >> +     .read           = seq_read,
>> >> >> +     .llseek         = seq_lseek,
>> >> >> +     .release        = single_release,
>> >> >> +};
>> >> >> +
>> >> >> +static int zs_pool_stat_create(struct zs_pool *pool, int index)
>> >> >> +{
>> >> >> +     char name[10];
>> >> >> +     int ret = 0;
>> >> >> +
>> >> >> +     if (!zs_stat_root) {
>> >> >> +             ret = -ENODEV;
>> >> >> +             goto out;
>> >> >> +     }
>> >> >> +
>> >> >> +     snprintf(name, sizeof(name), "pool-%d", index);
>> >> >
>> >> > Hmm, how does admin know any zsmalloc instance is associated with
>> >> > any block device?
>> >> > Maybe we need export zspool index to the client and print it
>> >> > when pool is populated.
>> >>
>> >> Thanks for your suggestion.
>> >>
>> >> >
>> >> >> +     pool->stat_dentry = debugfs_create_dir(name, zs_stat_root);
>> >> >> +     if (!pool->stat_dentry) {
>> >> >> +             ret = -ENOMEM;
>> >> >> +             goto out;
>> >> >> +     }
>> >> >> +
>> >> >> +     debugfs_create_file("obj_in_classes", S_IFREG | S_IRUGO,
>> >> >> +                     pool->stat_dentry, pool, &zs_stats_operations);
>> >> >
>> >> > No need to check return?
>> >>
>> >> It is better to check the return value and give user some information
>> >> about the failure.
>> >>
>> >> >
>> >> >> +
>> >> >> +out:
>> >> >> +     return ret;
>> >> >> +}
>> >> >> +
>> >> >> +static void zs_pool_stat_destroy(struct zs_pool *pool)
>> >> >> +{
>> >> >> +     debugfs_remove_recursive(pool->stat_dentry);
>> >> >> +}
>> >> >> +
>> >> >> +#else /* CONFIG_ZSMALLOC_STAT */
>> >> >> +
>> >> >> +static int __init zs_stat_init(void)
>> >> >> +{
>> >> >> +     return 0;
>> >> >> +}
>> >> >> +
>> >> >> +static void __exit zs_stat_exit(void) { }
>> >> >> +
>> >> >> +static inline int zs_pool_stat_create(struct zs_pool *pool, int index)
>> >> >> +{
>> >> >> +     return 0;
>> >> >> +}
>> >> >> +
>> >> >> +static inline void zs_pool_stat_destroy(struct zs_pool *pool) { }
>> >> >> +
>> >> >> +#endif
>> >> >> +
>> >> >>  unsigned long zs_get_total_pages(struct zs_pool *pool)
>> >> >>  {
>> >> >>       return atomic_long_read(&pool->pages_allocated);
>> >> >> @@ -1075,6 +1212,10 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
>> >> >>               atomic_long_add(class->pages_per_zspage,
>> >> >>                                       &pool->pages_allocated);
>> >> >>               spin_lock(&class->lock);
>> >> >> +#ifdef CONFIG_ZSMALLOC_STAT
>> >> >> +             class->obj_allocated += get_maxobj_per_zspage(class->size,
>> >> >> +                             class->pages_per_zspage);
>> >> >> +#endif
>> >> >
>> >> > I prefer zs_stat_inc(class, OBJ_ALLOCATED, get_max_obj());
>> >>
>> >> Got it. thanks
>> >>
>> >> >
>> >> >>       }
>> >> >>
>> >> >>       obj = (unsigned long)first_page->freelist;
>> >> >> @@ -1088,6 +1229,9 @@ unsigned long zs_malloc(struct zs_pool *pool, size_t size)
>> >> >>       kunmap_atomic(vaddr);
>> >> >>
>> >> >>       first_page->inuse++;
>> >> >> +#ifdef CONFIG_ZSMALLOC_STAT
>> >> >> +     class->obj_used++;
>> >> >> +#endif
>> >> >
>> >> > zs_stat_inc(class, OBJ_USED, 1)
>> >>
>> >> OK
>> >>
>> >> >
>> >> >
>> >> >>       /* Now move the zspage to another fullness group, if required */
>> >> >>       fix_fullness_group(pool, first_page);
>> >> >>       spin_unlock(&class->lock);
>> >> >> @@ -1127,12 +1271,19 @@ void zs_free(struct zs_pool *pool, unsigned long obj)
>> >> >>       first_page->freelist = (void *)obj;
>> >> >>
>> >> >>       first_page->inuse--;
>> >> >> +#ifdef CONFIG_ZSMALLOC_STAT
>> >> >> +     class->obj_used--;
>> >> >> +#endif
>> >> >
>> >> > zs_stat_dec(class, OBJ_USED, 1)
>> >>
>> >> OK
>> >>
>> >> >
>> >> >>       fullness = fix_fullness_group(pool, first_page);
>> >> >>       spin_unlock(&class->lock);
>> >> >>
>> >> >>       if (fullness == ZS_EMPTY) {
>> >> >>               atomic_long_sub(class->pages_per_zspage,
>> >> >>                               &pool->pages_allocated);
>> >> >> +#ifdef CONFIG_ZSMALLOC_STAT
>> >> >> +             class->obj_allocated -= get_maxobj_per_zspage(class->size,
>> >> >> +                             class->pages_per_zspage);
>> >> >> +#endif
>> >> >
>> >> > zs_stat_dec(class, OBJ_ALLOCATED, get_max_obj());
>> >> >
>> >> >>               free_zspage(first_page);
>> >> >>       }
>> >> >>  }
>> >> >> @@ -1209,6 +1360,10 @@ struct zs_pool *zs_create_pool(gfp_t flags)
>> >> >>       }
>> >> >>
>> >> >>       pool->flags = flags;
>> >> >> +     zs_pool_num++;
>> >> >
>> >> > Who protect the race?
>> >> > And manybe we should keep the index in zspool and export it to the user
>> >> > to let them know what zsmalloc instance is thiers.
>> >>
>> >> OK
>> >>
>> >> >
>> >> >> +
>> >> >> +     if (zs_pool_stat_create(pool, zs_pool_num))
>> >> >> +             pr_warn("zs pool %d stat initialization failed\n", zs_pool_num);
>> >> >>
>> >> >>       return pool;
>> >> >>
>> >> >> @@ -1241,6 +1396,9 @@ void zs_destroy_pool(struct zs_pool *pool)
>> >> >>               kfree(class);
>> >> >>       }
>> >> >>
>> >> >> +     zs_pool_stat_destroy(pool);
>> >> >> +     zs_pool_num--;
>> >> >> +
>> >> >>       kfree(pool->size_class);
>> >> >>       kfree(pool);
>> >> >>  }
>> >> >> @@ -1260,6 +1418,10 @@ static int __init zs_init(void)
>> >> >>  #ifdef CONFIG_ZPOOL
>> >> >>       zpool_register_driver(&zs_zpool_driver);
>> >> >>  #endif
>> >> >> +
>> >> >> +     if (zs_stat_init())
>> >> >> +             pr_warn("zs stat initialization failed\n");
>> >> >> +
>> >> >>       return 0;
>> >> >>  }
>> >> >>
>> >> >> @@ -1269,6 +1431,8 @@ static void __exit zs_exit(void)
>> >> >>       zpool_unregister_driver(&zs_zpool_driver);
>> >> >>  #endif
>> >> >>       zs_unregister_cpu_notifier();
>> >> >> +
>> >> >> +     zs_stat_exit();
>> >> >>  }
>> >> >>
>> >> >>  module_init(zs_init);
>> >> >> --
>> >> >> 1.7.9.5
>> >> >>
>> >>
>> >> --
>> >> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> >> the body to majordomo@kvack.org.  For more info on Linux MM,
>> >> see: http://www.linux-mm.org/ .
>> >> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>> >
>> > --
>> > Kind regards,
>> > Minchan Kim
>>
>> --
>> To unsubscribe, send a message with 'unsubscribe linux-mm' in
>> the body to majordomo@kvack.org.  For more info on Linux MM,
>> see: http://www.linux-mm.org/ .
>> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>
> --
> Kind regards,
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
