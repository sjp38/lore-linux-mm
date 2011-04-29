Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id E74D7900001
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 13:48:33 -0400 (EDT)
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id p3THmViH025434
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 10:48:31 -0700
Received: from qyk7 (qyk7.prod.google.com [10.241.83.135])
	by hpaq13.eem.corp.google.com with ESMTP id p3THmOGk020307
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 29 Apr 2011 10:48:30 -0700
Received: by qyk7 with SMTP id 7so430174qyk.5
        for <linux-mm@kvack.org>; Fri, 29 Apr 2011 10:48:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <BANLkTik6D5OYTLS0FcQ9BYDpy_J1+kpD6A@mail.gmail.com>
References: <1304030226-19332-1-git-send-email-yinghan@google.com>
	<20110429164415.GA2006@barrios-desktop>
	<BANLkTik6D5OYTLS0FcQ9BYDpy_J1+kpD6A@mail.gmail.com>
Date: Fri, 29 Apr 2011 10:48:23 -0700
Message-ID: <BANLkTi=qqiyyjJNVeEd14aDerPa0KLCkcA@mail.gmail.com>
Subject: Re: [PATCH 0/2] memcg: add the soft_limit reclaim in global direct reclaim
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org, Greg Thelen <gthelen@google.com>

On Fri, Apr 29, 2011 at 10:19 AM, Ying Han <yinghan@google.com> wrote:
> On Fri, Apr 29, 2011 at 9:44 AM, Minchan Kim <minchan.kim@gmail.com> wrot=
e:
>> Hi Ying,
>>
>> On Thu, Apr 28, 2011 at 03:37:04PM -0700, Ying Han wrote:
>>> We recently added the change in global background reclaim which counts =
the
>>> return value of soft_limit reclaim. Now this patch adds the similar log=
ic
>>> on global direct reclaim.
>>>
>>> We should skip scanning global LRU on shrink_zone if soft_limit reclaim=
 does
>>> enough work. This is the first step where we start with counting the nr=
_scanned
>>> and nr_reclaimed from soft_limit reclaim into global scan_control.
>>>
>>> The patch is based on mmotm-04-14 and i triggered kernel BUG at mm/vmsc=
an.c:1058!
>>
>> Could you tell me exact patches?
>> mmtom-04-14 + just 2 patch of this? or + something?
>>
>> These day, You and Kame produces many patches.
>> Do I have to apply something of them?
> No, I applied my patch on top of mmotm and here is the last commit
> before my patch.
>
> commit 66a3827927351e0f88dc391919cf0cda10d42dd7
> Author: Andrew Morton <akpm@linux-foundation.org>
> Date: =A0 Thu Apr 14 15:51:34 2011 -0700

sorry, please ignore the last post. I learned that the mmotm i posted
is based on
tag: mmotm-2011-04-14-15-08.

--Ying


>
>>
>>>
>>> [ =A0938.242033] kernel BUG at mm/vmscan.c:1058!
>>> [ =A0938.242033] invalid opcode: 0000 [#1] SMP=B7
>>> [ =A0938.242033] last sysfs file: /sys/devices/pci0000:00/0000:00:1f.2/=
device
>>> [ =A0938.242033] Pid: 546, comm: kswapd0 Tainted: G =A0 =A0 =A0 =A0W =
=A0 2.6.39-smp-direct_reclaim
>>> [ =A0938.242033] RIP: 0010:[<ffffffff810ed174>] =A0[<ffffffff810ed174>]=
 isolate_pages_global+0x18c/0x34f
>>> [ =A0938.242033] RSP: 0018:ffff88082f83bb50 =A0EFLAGS: 00010082
>>> [ =A0938.242033] RAX: 00000000ffffffea RBX: ffff88082f83bc90 RCX: 00000=
00000000401
>>> [ =A0938.242033] RDX: 0000000000000001 RSI: 0000000000000000 RDI: ffffe=
a001ca653e8
>>> [ =A0938.242033] RBP: ffff88082f83bc20 R08: 0000000000000000 R09: ffff8=
8085ffb6e00
>>> [ =A0938.242033] R10: ffff88085ffb73d0 R11: ffff88085ffb6e00 R12: ffff8=
8085ffb6e00
>>> [ =A0938.242033] R13: ffffea001ca65410 R14: 0000000000000001 R15: ffffe=
a001ca653e8
>>> [ =A0938.242033] FS: =A00000000000000000(0000) GS:ffff88085fd00000(0000=
) knlGS:0000000000000000
>>> [ =A0938.242033] CS: =A00010 DS: 0000 ES: 0000 CR0: 000000008005003b
>>> [ =A0938.242033] CR2: 00007f5c3405c320 CR3: 0000000001803000 CR4: 00000=
000000006e0
>>> [ =A0938.242033] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000=
00000000000
>>> [ =A0938.242033] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000=
00000000400
>>> [ =A0938.242033] Process kswapd0 (pid: 546, threadinfo ffff88082f83a000=
, task ffff88082fe52080)
>>> [ =A0938.242033] Stack:
>>> [ =A0938.242033] =A0ffff88085ffb6e00 ffffea0000000002 0000000000000021 =
0000000000000000
>>> [ =A0938.242033] =A00000000000000000 ffff88082f83bcb8 ffffea00108eec80 =
ffffea00108eecb8
>>> [ =A0938.242033] =A0ffffea00108eecf0 0000000000000004 fffffffffffffffc =
0000000000000020
>>> [ =A0938.242033] Call Trace:
>>> [ =A0938.242033] =A0[<ffffffff810ee8a5>] shrink_inactive_list+0x185/0x4=
18
>>> [ =A0938.242033] =A0[<ffffffff810366cc>] ? __switch_to+0xea/0x212
>>> [ =A0938.242033] =A0[<ffffffff810e8b35>] ? determine_dirtyable_memory+0=
x1a/0x2c
>>> [ =A0938.242033] =A0[<ffffffff810ef19b>] shrink_zone+0x380/0x44d
>>> [ =A0938.242033] =A0[<ffffffff810e5188>] ? zone_watermark_ok_safe+0xa1/=
0xae
>>> [ =A0938.242033] =A0[<ffffffff810efbd8>] kswapd+0x41b/0x76b
>>> [ =A0938.242033] =A0[<ffffffff810ef7bd>] ? zone_reclaim+0x2fb/0x2fb
>>> [ =A0938.242033] =A0[<ffffffff81088569>] kthread+0x82/0x8a
>>> [ =A0938.242033] =A0[<ffffffff8141b0d4>] kernel_thread_helper+0x4/0x10
>>> [ =A0938.242033] =A0[<ffffffff810884e7>] ? kthread_worker_fn+0x112/0x11=
2
>>> [ =A0938.242033] =A0[<ffffffff8141b0d0>] ? gs_change+0xb/0xb
>>>
>>
>> It seems there is active page in inactive list.
>> As I look deactivate_page, lru_deactivate_fn clears PageActive before
>> add_page_to_lru_list and it should be protected by zone->lru_lock.
>> In addiion, PageLRU would protect with race with isolation functions.
>>
>> Hmm, I don't have any clue now.
>> Is it reproducible easily?
> I can manage to reproduce it on my host by adding lots of memory
> pressure and then trigger the global
> reclaim.
>
>>
>> Could you apply below debugging patch and report the result?
>>
>> diff --git a/include/linux/mm_inline.h b/include/linux/mm_inline.h
>> index 8f7d247..f39b53a 100644
>> --- a/include/linux/mm_inline.h
>> +++ b/include/linux/mm_inline.h
>> @@ -25,6 +25,8 @@ static inline void
>> =A0__add_page_to_lru_list(struct zone *zone, struct page *page, enum lru=
_list l,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct list_head *head)
>> =A0{
>> + =A0 =A0 =A0 VM_BUG_ON(PageActive(page) && (
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 l =3D=3D LRU_INACTIVE_ANON=
 || l =3D=3D LRU_INACTIVE_FILE));
>> =A0 =A0 =A0 =A0list_add(&page->lru, head);
>> =A0 =A0 =A0 =A0__mod_zone_page_state(zone, NR_LRU_BASE + l, hpage_nr_pag=
es(page));
>> =A0 =A0 =A0 =A0mem_cgroup_add_lru_list(page, l);
>> diff --git a/mm/swap.c b/mm/swap.c
>> index a83ec5a..5f7c3c8 100644
>> --- a/mm/swap.c
>> +++ b/mm/swap.c
>> @@ -454,6 +454,8 @@ static void lru_deactivate_fn(struct page *page, voi=
d *arg)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * The page's writeback ends up during pa=
gevec
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 * We moves tha page into tail of inactiv=
e.
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 */
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 VM_BUG_ON(PageActive(page) && (
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lru =3D=3D LRU_INACTIVE_AN=
ON || lru =3D=3D LRU_INACTIVE_FILE));
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_move_tail(&page->lru, &zone->lru[lru=
].list);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_rotate_reclaimable_page(page);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__count_vm_event(PGROTATED);
>> diff --git a/mm/vmscan.c b/mm/vmscan.c
>> index b3a569f..3415896 100644
>> --- a/mm/vmscan.c
>> +++ b/mm/vmscan.c
>> @@ -963,7 +963,7 @@ int __isolate_lru_page(struct page *page, int mode, =
int file)
>>
>> =A0 =A0 =A0 =A0/* Only take pages on the LRU. */
>> =A0 =A0 =A0 =A0if (!PageLRU(page))
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
>>
>> =A0 =A0 =A0 =A0/*
>> =A0 =A0 =A0 =A0 * When checking the active state, we need to be sure we =
are
>> @@ -971,10 +971,10 @@ int __isolate_lru_page(struct page *page, int mode=
, int file)
>> =A0 =A0 =A0 =A0 * of each.
>> =A0 =A0 =A0 =A0 */
>> =A0 =A0 =A0 =A0if (mode !=3D ISOLATE_BOTH && (!PageActive(page) !=3D !mo=
de))
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 2;
>>
>> =A0 =A0 =A0 =A0if (mode !=3D ISOLATE_BOTH && page_is_file_cache(page) !=
=3D file)
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 3;
>>
>> =A0 =A0 =A0 =A0/*
>> =A0 =A0 =A0 =A0 * When this function is being called for lumpy reclaim, =
we
>> @@ -982,7 +982,7 @@ int __isolate_lru_page(struct page *page, int mode, =
int file)
>> =A0 =A0 =A0 =A0 * unevictable; only give shrink_page_list evictable page=
s.
>> =A0 =A0 =A0 =A0 */
>> =A0 =A0 =A0 =A0if (PageUnevictable(page))
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 4;
>>
>> =A0 =A0 =A0 =A0ret =3D -EBUSY;
>>
>> @@ -1035,13 +1035,14 @@ static unsigned long isolate_lru_pages(unsigned =
long nr_to_scan,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long end_pfn;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsigned long page_pfn;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0int zone_id;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int ret;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0page =3D lru_to_page(src);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0prefetchw_prev_lru_page(page, src, flags)=
;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0VM_BUG_ON(!PageLRU(page));
>>
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (__isolate_lru_page(page, mode, fil=
e)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 switch (ret =3D __isolate_lru_page(page, m=
ode, file)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0case 0:
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_move(&page->lru, dst=
);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_del_lru(page);
>> @@ -1055,6 +1056,7 @@ static unsigned long isolate_lru_pages(unsigned lo=
ng nr_to_scan,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0continue;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0default:
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR "ret %d\n"=
, ret);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BUG();
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>>
>>> Thank you Minchan for the pointer. I reverted the following commit and =
I
>>> haven't seen the problem with the same operation. I haven't looked deep=
ly
>>> on the patch yet, but figured it would be a good idea to post the dump.
>>> The dump looks not directly related to this patchset, but ppl can use i=
t to
>>> reproduce the problem.
>>
>> I tested the patch with rsync + fadvise several times
>> in my machine(2P, 2G DRAM) but I didn't have ever seen the BUG.
>> But I didn't test it in memcg. As I look dump, it seems not related to m=
emcg.
>> Anyway, I tried it to reproduce it in my machine.
>> Maybe I will start testing after next week. Sorry.
>>
>> I hope my debugging patch givse some clues.
>> Thanks for the reporting, Ying.
>
> Sure, i will try the patch and post the result.
>
> --Ying
>
>> --
>> Kind regards,
>> Minchan Kim
>>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
