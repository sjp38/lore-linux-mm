Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS autolearn=no autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id ED1EEECDE27
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 05:30:44 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 900BD21A4C
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 05:30:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 900BD21A4C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ah.jp.nec.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E69806B0005; Wed, 11 Sep 2019 01:30:43 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1AC26B0006; Wed, 11 Sep 2019 01:30:43 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D301E6B0007; Wed, 11 Sep 2019 01:30:43 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0020.hostedemail.com [216.40.44.20])
	by kanga.kvack.org (Postfix) with ESMTP id B344A6B0005
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 01:30:43 -0400 (EDT)
Received: from smtpin18.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay02.hostedemail.com (Postfix) with SMTP id 2404D1B669
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 05:30:43 +0000 (UTC)
X-FDA: 75921515166.18.comb26_7a706bde4ac04
X-HE-Tag: comb26_7a706bde4ac04
X-Filterd-Recvd-Size: 9186
Received: from tyo161.gate.nec.co.jp (tyo161.gate.nec.co.jp [114.179.232.161])
	by imf06.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 05:30:41 +0000 (UTC)
Received: from mailgate01.nec.co.jp ([114.179.233.122])
	by tyo161.gate.nec.co.jp (8.15.1/8.15.1) with ESMTPS id x8B5UYoV012081
	(version=TLSv1.2 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=NO);
	Wed, 11 Sep 2019 14:30:34 +0900
Received: from mailsv01.nec.co.jp (mailgate-v.nec.co.jp [10.204.236.94])
	by mailgate01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x8B5UYPZ011124;
	Wed, 11 Sep 2019 14:30:34 +0900
Received: from mail01b.kamome.nec.co.jp (mail01b.kamome.nec.co.jp [10.25.43.2])
	by mailsv01.nec.co.jp (8.15.1/8.15.1) with ESMTP id x8B5UY8O031774;
	Wed, 11 Sep 2019 14:30:34 +0900
Received: from bpxc99gp.gisp.nec.co.jp ([10.38.151.152] [10.38.151.152]) by mail02.kamome.nec.co.jp with ESMTP id BT-MMP-8360946; Wed, 11 Sep 2019 14:29:57 +0900
Received: from BPXM23GP.gisp.nec.co.jp ([10.38.151.215]) by
 BPXC24GP.gisp.nec.co.jp ([10.38.151.152]) with mapi id 14.03.0439.000; Wed,
 11 Sep 2019 14:29:56 +0900
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
To: Oscar Salvador <osalvador@suse.de>
CC: "mhocko@kernel.org" <mhocko@kernel.org>,
        "mike.kravetz@oracle.com" <mike.kravetz@oracle.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH 00/10] Hwpoison soft-offline rework
Thread-Topic: [PATCH 00/10] Hwpoison soft-offline rework
Thread-Index: AQHVZ8LTy7PIWQBirkyAnAoCBs9f5aclXX4A
Date: Wed, 11 Sep 2019 05:29:56 +0000
Message-ID: <20190911052956.GA9729@hori.linux.bs1.fc.nec.co.jp>
References: <20190910103016.14290-1-osalvador@suse.de>
In-Reply-To: <20190910103016.14290-1-osalvador@suse.de>
Accept-Language: en-US, ja-JP
Content-Language: ja-JP
X-MS-Has-Attach:
X-MS-TNEF-Correlator:
x-originating-ip: [10.34.125.150]
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <8CFCB2FA6A53DB4DAE162B2CFFF6DE8F@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-TM-AS-MML: disable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Oscar,

Thank you for your working on this.

My testing shows the following error:

  [ 1926.932435] =3D=3D=3D> testcase 'mce_ksm_soft-offline_avoid_access.aut=
o2' start
  [ 1927.155321] bash (15853): drop_caches: 3
  [ 1929.019094] page:ffffe5c384c4cd40 refcount:1 mapcount:0 mapping:000000=
0000000003 index:0x700000001
  [ 1929.021586] anon
  [ 1929.021588] flags: 0x57ffe00088000e(referenced|uptodate|dirty|swapback=
ed|hwpoison)
  [ 1929.024289] raw: 0057ffe00088000e dead000000000100 dead000000000122 00=
00000000000003
  [ 1929.026611] raw: 0000000700000001 0000000000000000 00000000ffffffff 00=
00000000000000
  [ 1929.028760] page dumped because: VM_BUG_ON_PAGE(page_ref_count(page))
  [ 1929.030559] ------------[ cut here ]------------
  [ 1929.031684] kernel BUG at mm/internal.h:73!
  [ 1929.032738] invalid opcode: 0000 [#1] SMP PTI
  [ 1929.033941] CPU: 3 PID: 16052 Comm: mceinj.sh Not tainted 5.3.0-rc8-v5=
.3-rc8-190911-1025-00010-ga436dbce8674+ #18
  [ 1929.037137] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIO=
S 1.12.0-2.fc30 04/01/2014
  [ 1929.040066] RIP: 0010:page_set_poison+0xf9/0x160
  [ 1929.041665] Code: 63 02 7f 31 c0 5b 5d 41 5c c3 48 c7 c6 d0 d1 0c b0 4=
8 89 df e8 88 bb f8 ff 0f 0b 48 c7 c6 f0 2a 0d b0 48 89 df e8 77 bb f8 ff <=
0f> 0b 48 8b 45 00 48 c1 e8 33 83 e0 07 83 f8 04 75 89 48 8b 45 08
  [ 1929.047773] RSP: 0018:ffffb4fb8a73bde0 EFLAGS: 00010246
  [ 1929.049511] RAX: 0000000000000039 RBX: ffffe5c384c4cd40 RCX: 000000000=
0000000
  [ 1929.051870] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffffffb=
00d1814
  [ 1929.054238] RBP: ffffe5c384c4cd40 R08: 0000000000000596 R09: 000000000=
0000048
  [ 1929.056599] R10: 0000000000000000 R11: ffffb4fb8a73bc58 R12: 000000000=
0000000
  [ 1929.058986] R13: ffffb4fb8a73be10 R14: 0000000000131335 R15: 000000000=
0000001
  [ 1929.061366] FS:  00007fc9e208d740(0000) GS:ffff9fa9bdb00000(0000) knlG=
S:0000000000000000
  [ 1929.063842] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
  [ 1929.065429] CR2: 000055946c05d192 CR3: 00000001365f2000 CR4: 000000000=
01406e0
  [ 1929.067373] Call Trace:
  [ 1929.068094]  soft_offline_page+0x2be/0x600
  [ 1929.069246]  soft_offline_page_store+0xdf/0x110
  [ 1929.070510]  kernfs_fop_write+0x116/0x190
  [ 1929.071618]  vfs_write+0xa5/0x1a0
  [ 1929.072614]  ksys_write+0x59/0xd0
  [ 1929.073548]  do_syscall_64+0x5f/0x1a0
  [ 1929.074554]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
  [ 1929.075957] RIP: 0033:0x7fc9e217ded8

It seems that soft-offlining on ksm pages is affected by this changeset.
Could you try to handle this?

- Naoya

On Tue, Sep 10, 2019 at 12:30:06PM +0200, Oscar Salvador wrote:
>
> This patchset was based on Naoya's hwpoison rework [1], so thanks to him
> for the initial work.
>
> This patchset aims to fix some issues laying in soft-offline handling,
> but it also takes the chance and takes some further steps to perform
> cleanups and some refactoring as well.
>
>  - Motivation:
>
>    A customer and I were facing an issue where poisoned pages we returned
>    back to user-space after having offlined them properly.
>    This was only seend under some memory stress + soft offlining pages.
>    After some anaylsis, it became clear that the problem was that
>    when kcompactd kicked in to migrate pages over, compaction_alloc
>    callback was handing poisoned pages to the migrate routine.
>    Once this page was later on fault in, __do_page_fault returned
>    VM_FAULT_HWPOISON making the process being killed.
>
>    All this could happen because isolate_freepages_block and
>    fast_isolate_freepages just check for the page to be PageBuddy,
>    and since 1) poisoned pages can be part of a higher order page
>    and 2) poisoned pages are also Page Buddy, they can sneak in easily.
>
>    I also saw some problem with swap pages, but I suspected to be the
>    same sort of problem, so I did not follow that trace.
>
>    The full explanation can be see in [2].
>
>  - Approach:
>
>    The taken approach is to not let poisoned pages hit neither
>    pcplists nor buddy freelists.
>    This is achieved by:
>
> In-use pages:
>
>    * Normal pages
>
>    1) do not release the last reference count after the
>       invalidation/migration of the page.
>    2) the page is being handed to page_set_poison, which does:
>       2a) sets PageHWPoison flag
>       2b) calls put_page (only to be able to call __page_cache_release)
>           Since poisoned pages are skipped in free_pages_prepare,
>           this put_page is safe.
>       2c) Sets the refcount to 1
>
>    * Hugetlb pages
>
>    1) Hand the page to page_set_poison after migration
>    2) page_set_poison does:
>       2a) Calls dissolve_free_huge_page
>       2b) If ranged to be dissolved contains poisoned pages,
>           we free the rangeas order-0 pages (as we do with gigantic huget=
lb page),
>           so free_pages_prepare will skip them accordingly.
>       2c) Sets the refcount to 1
>
> Free pages:
>
>    * Normal pages:
>
>    1) Take the page off the buddy freelist
>    2) Set PageHWPoison flag and set refcount to 1
>
>    * Hugetlb pages
>
>    1) Try to allocate a new hugetlb page to the pool
>    2) Take off the pool the poisoned hugetlb
>
>
> With this patchset, I no longer see the issues I faced before.
>
> Note:
> I presented this as RFC to open discussion of the taken aproach.
> I think that furthers cleanups and refactors could be made, but I would
> like to get some insight of the taken approach before touching more
> code.
>
> Thanks
>
> [1] https://lore.kernel.org/linux-mm/1541746035-13408-1-git-send-email-n-=
horiguchi@ah.jp.nec.com/
> [2] https://lore.kernel.org/linux-mm/20190826104144.GA7849@linux/T/#u
>
> Naoya Horiguchi (5):
>   mm,hwpoison: cleanup unused PageHuge() check
>   mm,madvise: call soft_offline_page() without MF_COUNT_INCREASED
>   mm,hwpoison-inject: don't pin for hwpoison_filter
>   mm,hwpoison: remove MF_COUNT_INCREASED
>   mm: remove flag argument from soft offline functions
>
> Oscar Salvador (5):
>   mm,hwpoison: Unify THP handling for hard and soft offline
>   mm,hwpoison: Rework soft offline for in-use pages
>   mm,hwpoison: Refactor soft_offline_huge_page and __soft_offline_page
>   mm,hwpoison: Rework soft offline for free pages
>   mm,hwpoison: Use hugetlb_replace_page to replace free hugetlb pages
>
>  drivers/base/memory.c      |   2 +-
>  include/linux/mm.h         |   9 +-
>  include/linux/page-flags.h |   5 -
>  mm/hugetlb.c               |  51 +++++++-
>  mm/hwpoison-inject.c       |  18 +--
>  mm/madvise.c               |  25 ++--
>  mm/memory-failure.c        | 319 +++++++++++++++++++++------------------=
------
>  mm/migrate.c               |  11 +-
>  mm/page_alloc.c            |  62 +++++++--
>  9 files changed, 267 insertions(+), 235 deletions(-)
>
> --
> 2.12.3
>
>=


