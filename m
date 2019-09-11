Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=no
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 44E54ECDE20
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 06:35:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C95B921D79
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 06:35:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C95B921D79
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2C6366B0007; Wed, 11 Sep 2019 02:35:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 27F356B0008; Wed, 11 Sep 2019 02:35:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 18CBE6B000A; Wed, 11 Sep 2019 02:35:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0180.hostedemail.com [216.40.44.180])
	by kanga.kvack.org (Postfix) with ESMTP id E55066B0007
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 02:35:28 -0400 (EDT)
Received: from smtpin02.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 8C950181AC9C9
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 06:35:28 +0000 (UTC)
X-FDA: 75921678336.02.mask04_69f091504ee45
X-HE-Tag: mask04_69f091504ee45
X-Filterd-Recvd-Size: 11950
Received: from mx1.suse.de (mx2.suse.de [195.135.220.15])
	by imf24.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 06:35:27 +0000 (UTC)
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 742D0AC8C;
	Wed, 11 Sep 2019 06:35:26 +0000 (UTC)
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Date: Wed, 11 Sep 2019 08:35:26 +0200
From: osalvador@suse.de
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: mhocko@kernel.org, mike.kravetz@oracle.com, linux-mm@kvack.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH 00/10] Hwpoison soft-offline rework
In-Reply-To: <20190911062246.GA31960@hori.linux.bs1.fc.nec.co.jp>
References: <20190910103016.14290-1-osalvador@suse.de>
 <20190911052956.GA9729@hori.linux.bs1.fc.nec.co.jp>
 <20190911062246.GA31960@hori.linux.bs1.fc.nec.co.jp>
Message-ID: <59dce1bc205b10f67f17cf9d2e1e7a04@suse.de>
X-Sender: osalvador@suse.de
User-Agent: Roundcube Webmail
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-09-11 08:22, Naoya Horiguchi wrote:
> I found another panic ...

Hi Naoya,

Thanks for giving it a try. Are these testcase public?
I will definetely take a look and try to solve these cases.

Thanks!
>=20
> This testcase is testing the corner case where hugepage migration fails
> by allocation failure on destination numa node which is caused by the
> condition that all remaining free hugetlb are reserved.
>=20
>   [ 2610.711713] =3D=3D=3D> testcase
> 'page_migration/hugetlb_madv_soft_reserve_noovercommit.auto2' start
>   [ 2610.995836] bash (15807): drop_caches: 3
>   [ 2612.596154] Soft offlining pfn 0x1d000 at process virtual address
> 0x700000000000
>   [ 2612.910245] bash (15807): drop_caches: 3
>   [ 2613.099769] page:fffff4ba40740000 refcount:1 mapcount:-128
> mapping:0000000000000000 index:0x0
>   [ 2613.102099] flags: 0xfffe000800000(hwpoison)
>   [ 2613.103424] raw: 000fffe000800000 ffff9c953ffd5af8
> fffff4ba40e78008 0000000000000000
>   [ 2613.105817] raw: 0000000000000000 0000000000000009
> 00000001ffffff7f 0000000000000000
>   [ 2613.107703] page dumped because: VM_BUG_ON_PAGE(page_count(buddy)=20
> !=3D 0)
>   [ 2613.109485] ------------[ cut here ]------------
>   [ 2613.110834] kernel BUG at mm/page_alloc.c:821!
>   [ 2613.112015] invalid opcode: 0000 [#1] SMP PTI
>   [ 2613.113245] CPU: 0 PID: 16195 Comm: sysctl Not tainted
> 5.3.0-rc8-v5.3-rc8-190911-1025-00010-ga436dbce8674+ #18
>   [ 2613.115982] Hardware name: QEMU Standard PC (i440FX + PIIX,
> 1996), BIOS 1.12.0-2.fc30 04/01/2014
>   [ 2613.118495] RIP: 0010:free_one_page+0x5f1/0x610
>   [ 2613.119803] Code: 09 7e 81 49 8d b4 17 c0 00 00 00 8b 14 24 48 89
> ef e8 83 75 00 00 e9 16 fe ff ff 48 c7 c6 c0 2b 0d 82 4c 89 e7 e8 9f
> c3 fd ff <0f> 0b 48 c7 c6 c0 2b 0d 82 e8 91 c3 fd ff 0f 0b 66 66 2e 0f
> 1f 84
>   [ 2613.124751] RSP: 0018:ffffac7442727ca8 EFLAGS: 00010046
>   [ 2613.126224] RAX: 000000000000003b RBX: 0000000000000009 RCX:
> 0000000000000006
>   [ 2613.128261] RDX: 0000000000000000 RSI: 0000000000000000 RDI:
> ffffffff820d1814
>   [ 2613.130299] RBP: fffff4ba40748000 R08: 0000000000000710 R09:
> 000000000000004a
>   [ 2613.132082] R10: 0000000000000000 R11: ffffac7442727b20 R12:
> fffff4ba40740000
>   [ 2613.133821] R13: 000000000001d200 R14: 0000000000000000 R15:
> ffff9c953ffd5680
>   [ 2613.135769] FS:  00007fbf2e6cb900(0000) GS:ffff9c953da00000(0000)
> knlGS:0000000000000000
>   [ 2613.138077] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>   [ 2613.139721] CR2: 000055eef99d4d38 CR3: 000000007cb50000 CR4:
> 00000000001406f0
>   [ 2613.141747] Call Trace:
>   [ 2613.142472]  __free_pages_ok+0x175/0x4e0
>   [ 2613.143454]  free_pool_huge_page+0xec/0x100
>   [ 2613.144500]  __nr_hugepages_store_common+0x173/0x2e0
>   [ 2613.145968]  ? __do_proc_doulongvec_minmax+0x3ae/0x440
>   [ 2613.147444]  hugetlb_sysctl_handler_common+0xad/0xc0
>   [ 2613.148867]  proc_sys_call_handler+0x1a5/0x1c0
>   [ 2613.150104]  vfs_write+0xa5/0x1a0
>   [ 2613.151081]  ksys_write+0x59/0xd0
>   [ 2613.152052]  do_syscall_64+0x5f/0x1a0
>   [ 2613.153071]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
>   [ 2613.154327] RIP: 0033:0x7fbf2eb01ed8
>=20
>=20
> On Wed, Sep 11, 2019 at 05:29:56AM +0000, Horiguchi Naoya(=E5=A0=80=E5=8F=
=A3 =E7=9B=B4=E4=B9=9F) wrote:
>> Hi Oscar,
>>=20
>> Thank you for your working on this.
>>=20
>> My testing shows the following error:
>>=20
>>   [ 1926.932435] =3D=3D=3D> testcase=20
>> 'mce_ksm_soft-offline_avoid_access.auto2' start
>>   [ 1927.155321] bash (15853): drop_caches: 3
>>   [ 1929.019094] page:ffffe5c384c4cd40 refcount:1 mapcount:0=20
>> mapping:0000000000000003 index:0x700000001
>>   [ 1929.021586] anon
>>   [ 1929.021588] flags:=20
>> 0x57ffe00088000e(referenced|uptodate|dirty|swapbacked|hwpoison)
>>   [ 1929.024289] raw: 0057ffe00088000e dead000000000100=20
>> dead000000000122 0000000000000003
>>   [ 1929.026611] raw: 0000000700000001 0000000000000000=20
>> 00000000ffffffff 0000000000000000
>>   [ 1929.028760] page dumped because:=20
>> VM_BUG_ON_PAGE(page_ref_count(page))
>>   [ 1929.030559] ------------[ cut here ]------------
>>   [ 1929.031684] kernel BUG at mm/internal.h:73!
>>   [ 1929.032738] invalid opcode: 0000 [#1] SMP PTI
>>   [ 1929.033941] CPU: 3 PID: 16052 Comm: mceinj.sh Not tainted=20
>> 5.3.0-rc8-v5.3-rc8-190911-1025-00010-ga436dbce8674+ #18
>>   [ 1929.037137] Hardware name: QEMU Standard PC (i440FX + PIIX,=20
>> 1996), BIOS 1.12.0-2.fc30 04/01/2014
>>   [ 1929.040066] RIP: 0010:page_set_poison+0xf9/0x160
>>   [ 1929.041665] Code: 63 02 7f 31 c0 5b 5d 41 5c c3 48 c7 c6 d0 d1 0c=
=20
>> b0 48 89 df e8 88 bb f8 ff 0f 0b 48 c7 c6 f0 2a 0d b0 48 89 df e8 77=20
>> bb f8 ff <0f> 0b 48 8b 45 00 48 c1 e8 33 83 e0 07 83 f8 04 75 89 48 8b=
=20
>> 45 08
>>   [ 1929.047773] RSP: 0018:ffffb4fb8a73bde0 EFLAGS: 00010246
>>   [ 1929.049511] RAX: 0000000000000039 RBX: ffffe5c384c4cd40 RCX:=20
>> 0000000000000000
>>   [ 1929.051870] RDX: 0000000000000000 RSI: 0000000000000000 RDI:=20
>> ffffffffb00d1814
>>   [ 1929.054238] RBP: ffffe5c384c4cd40 R08: 0000000000000596 R09:=20
>> 0000000000000048
>>   [ 1929.056599] R10: 0000000000000000 R11: ffffb4fb8a73bc58 R12:=20
>> 0000000000000000
>>   [ 1929.058986] R13: ffffb4fb8a73be10 R14: 0000000000131335 R15:=20
>> 0000000000000001
>>   [ 1929.061366] FS:  00007fc9e208d740(0000) GS:ffff9fa9bdb00000(0000)=
=20
>> knlGS:0000000000000000
>>   [ 1929.063842] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>   [ 1929.065429] CR2: 000055946c05d192 CR3: 00000001365f2000 CR4:=20
>> 00000000001406e0
>>   [ 1929.067373] Call Trace:
>>   [ 1929.068094]  soft_offline_page+0x2be/0x600
>>   [ 1929.069246]  soft_offline_page_store+0xdf/0x110
>>   [ 1929.070510]  kernfs_fop_write+0x116/0x190
>>   [ 1929.071618]  vfs_write+0xa5/0x1a0
>>   [ 1929.072614]  ksys_write+0x59/0xd0
>>   [ 1929.073548]  do_syscall_64+0x5f/0x1a0
>>   [ 1929.074554]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
>>   [ 1929.075957] RIP: 0033:0x7fc9e217ded8
>>=20
>> It seems that soft-offlining on ksm pages is affected by this=20
>> changeset.
>> Could you try to handle this?
>>=20
>> - Naoya
>>=20
>> On Tue, Sep 10, 2019 at 12:30:06PM +0200, Oscar Salvador wrote:
>> >
>> > This patchset was based on Naoya's hwpoison rework [1], so thanks to=
 him
>> > for the initial work.
>> >
>> > This patchset aims to fix some issues laying in soft-offline handlin=
g,
>> > but it also takes the chance and takes some further steps to perform
>> > cleanups and some refactoring as well.
>> >
>> >  - Motivation:
>> >
>> >    A customer and I were facing an issue where poisoned pages we ret=
urned
>> >    back to user-space after having offlined them properly.
>> >    This was only seend under some memory stress + soft offlining pag=
es.
>> >    After some anaylsis, it became clear that the problem was that
>> >    when kcompactd kicked in to migrate pages over, compaction_alloc
>> >    callback was handing poisoned pages to the migrate routine.
>> >    Once this page was later on fault in, __do_page_fault returned
>> >    VM_FAULT_HWPOISON making the process being killed.
>> >
>> >    All this could happen because isolate_freepages_block and
>> >    fast_isolate_freepages just check for the page to be PageBuddy,
>> >    and since 1) poisoned pages can be part of a higher order page
>> >    and 2) poisoned pages are also Page Buddy, they can sneak in easi=
ly.
>> >
>> >    I also saw some problem with swap pages, but I suspected to be th=
e
>> >    same sort of problem, so I did not follow that trace.
>> >
>> >    The full explanation can be see in [2].
>> >
>> >  - Approach:
>> >
>> >    The taken approach is to not let poisoned pages hit neither
>> >    pcplists nor buddy freelists.
>> >    This is achieved by:
>> >
>> > In-use pages:
>> >
>> >    * Normal pages
>> >
>> >    1) do not release the last reference count after the
>> >       invalidation/migration of the page.
>> >    2) the page is being handed to page_set_poison, which does:
>> >       2a) sets PageHWPoison flag
>> >       2b) calls put_page (only to be able to call __page_cache_relea=
se)
>> >           Since poisoned pages are skipped in free_pages_prepare,
>> >           this put_page is safe.
>> >       2c) Sets the refcount to 1
>> >
>> >    * Hugetlb pages
>> >
>> >    1) Hand the page to page_set_poison after migration
>> >    2) page_set_poison does:
>> >       2a) Calls dissolve_free_huge_page
>> >       2b) If ranged to be dissolved contains poisoned pages,
>> >           we free the rangeas order-0 pages (as we do with gigantic =
hugetlb page),
>> >           so free_pages_prepare will skip them accordingly.
>> >       2c) Sets the refcount to 1
>> >
>> > Free pages:
>> >
>> >    * Normal pages:
>> >
>> >    1) Take the page off the buddy freelist
>> >    2) Set PageHWPoison flag and set refcount to 1
>> >
>> >    * Hugetlb pages
>> >
>> >    1) Try to allocate a new hugetlb page to the pool
>> >    2) Take off the pool the poisoned hugetlb
>> >
>> >
>> > With this patchset, I no longer see the issues I faced before.
>> >
>> > Note:
>> > I presented this as RFC to open discussion of the taken aproach.
>> > I think that furthers cleanups and refactors could be made, but I wo=
uld
>> > like to get some insight of the taken approach before touching more
>> > code.
>> >
>> > Thanks
>> >
>> > [1] https://lore.kernel.org/linux-mm/1541746035-13408-1-git-send-ema=
il-n-horiguchi@ah.jp.nec.com/
>> > [2] https://lore.kernel.org/linux-mm/20190826104144.GA7849@linux/T/#=
u
>> >
>> > Naoya Horiguchi (5):
>> >   mm,hwpoison: cleanup unused PageHuge() check
>> >   mm,madvise: call soft_offline_page() without MF_COUNT_INCREASED
>> >   mm,hwpoison-inject: don't pin for hwpoison_filter
>> >   mm,hwpoison: remove MF_COUNT_INCREASED
>> >   mm: remove flag argument from soft offline functions
>> >
>> > Oscar Salvador (5):
>> >   mm,hwpoison: Unify THP handling for hard and soft offline
>> >   mm,hwpoison: Rework soft offline for in-use pages
>> >   mm,hwpoison: Refactor soft_offline_huge_page and __soft_offline_pa=
ge
>> >   mm,hwpoison: Rework soft offline for free pages
>> >   mm,hwpoison: Use hugetlb_replace_page to replace free hugetlb page=
s
>> >
>> >  drivers/base/memory.c      |   2 +-
>> >  include/linux/mm.h         |   9 +-
>> >  include/linux/page-flags.h |   5 -
>> >  mm/hugetlb.c               |  51 +++++++-
>> >  mm/hwpoison-inject.c       |  18 +--
>> >  mm/madvise.c               |  25 ++--
>> >  mm/memory-failure.c        | 319 +++++++++++++++++++++-------------=
-----------
>> >  mm/migrate.c               |  11 +-
>> >  mm/page_alloc.c            |  62 +++++++--
>> >  9 files changed, 267 insertions(+), 235 deletions(-)
>> >
>> > --
>> > 2.12.3
>> >
>> >
>>=20


