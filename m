Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F994C3A5A5
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 06:13:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C8F720828
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 06:13:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="YjRuCzff";
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="BGGBVzaR"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C8F720828
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 85D766B0003; Tue,  3 Sep 2019 02:13:23 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 80CE26B0005; Tue,  3 Sep 2019 02:13:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 723926B0006; Tue,  3 Sep 2019 02:13:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0232.hostedemail.com [216.40.44.232])
	by kanga.kvack.org (Postfix) with ESMTP id 51A0F6B0003
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 02:13:23 -0400 (EDT)
Received: from smtpin03.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id EA0F5181AC9B6
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 06:13:22 +0000 (UTC)
X-FDA: 75892592244.03.rat76_1d7264b60c62b
X-HE-Tag: rat76_1d7264b60c62b
X-Filterd-Recvd-Size: 8498
Received: from smtp.codeaurora.org (smtp.codeaurora.org [198.145.29.96])
	by imf01.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 06:13:22 +0000 (UTC)
Received: by smtp.codeaurora.org (Postfix, from userid 1000)
	id 28B59607C3; Tue,  3 Sep 2019 06:13:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1567491201;
	bh=EAThsBaKcYZgko7XipbHIzYcjvnW9rfcyExadPugr44=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=YjRuCzffDR0Ta/vqhsQlCpClQhMT4touEh2P5yT3UbCE0fAVnBALg3LL2NRs5B03u
	 eXlhphuOaSTZQ+M6ZCuxVKgnQ+6UneYpLXZKmziShJlePqITLT4lOFA8ajmSwOCCtF
	 2+dsNHVvdqIJL+DXiKNSUF9AttIOu7IbSJh/gCPQ=
Received: from [10.204.83.131] (blr-c-bdr-fw-01_globalnat_allzones-outside.qualcomm.com [103.229.19.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: vinmenon@smtp.codeaurora.org)
	by smtp.codeaurora.org (Postfix) with ESMTPSA id 1CFA0602EE;
	Tue,  3 Sep 2019 06:13:18 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1567491200;
	bh=EAThsBaKcYZgko7XipbHIzYcjvnW9rfcyExadPugr44=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=BGGBVzaR4+yVAPRuQX26dJIU+QxDJ5GMiWwA742nZRo/S3rIgw0dulbCChytmNZ+S
	 QEvdGKudd/efBSe+YZgx1aUWqoGhQWEgdrHIKA9rbrkhjnRR8KCgx87D5KT9B82EdF
	 oLBB1OHFs2dqJHst0A5yswD9cFQCb0K2whWkR3i4=
DMARC-Filter: OpenDMARC Filter v1.3.2 smtp.codeaurora.org 1CFA0602EE
Authentication-Results: pdx-caf-mail.web.codeaurora.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: pdx-caf-mail.web.codeaurora.org; spf=none smtp.mailfrom=vinmenon@codeaurora.org
Subject: Re: [PATCH] mm: fix the race between swapin_readahead and
 SWP_SYNCHRONOUS_IO path
To: Michal Hocko <mhocko@kernel.org>
Cc: minchan@kernel.org, linux-mm@kvack.org
References: <1567169011-4748-1-git-send-email-vinmenon@codeaurora.org>
 <20190902132104.GJ14028@dhcp22.suse.cz>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <79303914-d6a6-011a-150f-74488c8e12f2@codeaurora.org>
Date: Tue, 3 Sep 2019 11:43:16 +0530
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190902132104.GJ14028@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Michal,

Thanks for reviewing this.


On 9/2/2019 6:51 PM, Michal Hocko wrote:
> On Fri 30-08-19 18:13:31, Vinayak Menon wrote:
>> The following race is observed due to which a processes faulting
>> on a swap entry, finds the page neither in swapcache nor swap. This
>> causes zram to give a zero filled page that gets mapped to the
>> process, resulting in a user space crash later.
>>
>> Consider parent and child processes Pa and Pb sharing the same swap
>> slot with swap_count 2. Swap is on zram with SWP_SYNCHRONOUS_IO set.
>> Virtual address 'VA' of Pa and Pb points to the shared swap entry.
>>
>> Pa                                       Pb
>>
>> fault on VA                              fault on VA
>> do_swap_page                             do_swap_page
>> lookup_swap_cache fails                  lookup_swap_cache fails
>>                                          Pb scheduled out
>> swapin_readahead (deletes zram entry)
>> swap_free (makes swap_count 1)
>>                                          Pb scheduled in
>>                                          swap_readpage (swap_count =3D=
=3D 1)
>>                                          Takes SWP_SYNCHRONOUS_IO path
>>                                          zram enrty absent
>>                                          zram gives a zero filled page
> This sounds like a zram issue, right? Why is a generic swap path change=
d
> then?


I think zram entry being deleted by Pa and zram giving out a zeroed page =
to Pb is normal.

This is because zram avoids lazy swap slot freeing by implementing gendis=
k->fops->swap_slot_free_notify

and swap_slot_free_notify deletes the zram entry because the page is in s=
wapcache.

The issue is that Pb attempted a swapcache lookup before Pa brought the p=
age to swapcache, and failed. If

Pb had taken the swapin_readahead path, __read_swap_cache_async would hav=
e performed a second lookup

and found the page in swapcache. The issue here is that due to the lookup=
 failure and swap_count being 1,

it takes the=C2=A0 SWP_SYNCHRONOUS_IO path and does a direct read which i=
s bound to fail. So it seems to me as

a problem in the way SWP_SYNCHRONOUS_IO is handled in do_swap_page, and n=
ot a problem with zram.

Any swap device that sets SWP_SYNCHRONOUS_IO and implements swap_slot_fre=
e_notify can hit this bug.

do_swap_page first brings in the page to swapcache and then decrements th=
e swap_count, and SWP_SYNCHRONOUS_IO

code in do_swap_page performs the swapcache and swap_count checks in the =
same order. Due to thread preemption

described in the sequence above, it can happen that the SWP_SYNCHRONOUS_I=
O path fails in swapcache check, but sees

the swap_count decremented later, thus missing a valid swapcache entry.

I have not tested, but the following patch may also fix the issue.


diff --git a/include/linux/swap.h b/include/linux/swap.h
index 063c0c1..a5ca05f 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -463,6 +463,7 @@ extern sector_t map_swap_page(struct page *, struct b=
lock_device **);
=C2=A0extern sector_t swapdev_block(int, pgoff_t);
=C2=A0extern int page_swapcount(struct page *);
=C2=A0extern int __swap_count(swp_entry_t entry);
+extern bool __swap_has_cache(swp_entry_t entry);
=C2=A0extern int __swp_swapcount(swp_entry_t entry);
=C2=A0extern int swp_swapcount(swp_entry_t entry);
=C2=A0extern struct swap_info_struct *page_swap_info(struct page *);
@@ -589,6 +590,11 @@ static inline int __swap_count(swp_entry_t entry)
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return 0;
=C2=A0}

+static bool __swap_has_cache(swp_entry_t entry)
+{
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return 0;
+}
+
=C2=A0static inline int __swp_swapcount(swp_entry_t entry)
=C2=A0{
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return 0;

diff --git a/mm/memory.c b/mm/memory.c
index e0c232f..a13511f 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -2778,7 +2778,8 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0 struct swap_info_struct *si =3D swp_swap_info(entry);

=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0 if (si->flags & SWP_SYNCHRONOUS_IO &&
-=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 __swap_count(entry) =3D=3D 1) {
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 __swap_count(entry) =3D=3D 1 &&
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 !__swap_has_cache(entry)) {
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 /* skip s=
wapcache */
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 page =3D =
alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma,
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 vmf->address);
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 80445f4..2a1554a8 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1459,6 +1459,20 @@ int __swap_count(swp_entry_t entry)
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return count;
=C2=A0}

+bool __swap_has_cache(swp_entry_t entry)
+{
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 struct swap_info_struct *si;
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 pgoff_t offset =3D swp_offset(entry=
);
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 bool has_cache=C2=A0 =3D false;
+
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 si =3D get_swap_device(entry);
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (si) {
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 has_cache =3D !!(si->swap_map[offset] & SWAP_HAS_CACHE);
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 put_swap_device(si);
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 }
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return has_cache;
+}
+
=C2=A0static int swap_swapcount(struct swap_info_struct *si, swp_entry_t =
entry)
=C2=A0{
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 int count =3D 0;


>
>> Fix this by reading the swap_count before lookup_swap_cache, which con=
forms
>> with the order in which page is added to swap cache and swap count is
>> decremented in do_swap_page. In the race case above, this will let Pb =
take
>> the readahead path and thus pick the proper page from swapcache.
>>
>> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>

