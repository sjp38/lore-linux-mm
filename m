Return-Path: <SRS0=JR82=XF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1712C3A5A2
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 08:22:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4223121D6C
	for <linux-mm@archiver.kernel.org>; Tue, 10 Sep 2019 08:22:43 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="Wn/0wZXr";
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="YFJuoKMo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4223121D6C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB3DE6B0003; Tue, 10 Sep 2019 04:22:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D63FD6B0006; Tue, 10 Sep 2019 04:22:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C54816B0007; Tue, 10 Sep 2019 04:22:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0250.hostedemail.com [216.40.44.250])
	by kanga.kvack.org (Postfix) with ESMTP id A454A6B0003
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 04:22:42 -0400 (EDT)
Received: from smtpin23.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay03.hostedemail.com (Postfix) with SMTP id 4851C8243765
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 08:22:42 +0000 (UTC)
X-FDA: 75918319764.23.mark14_6ed76a2d6d038
X-HE-Tag: mark14_6ed76a2d6d038
X-Filterd-Recvd-Size: 10393
Received: from smtp.codeaurora.org (smtp.codeaurora.org [198.145.29.96])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue, 10 Sep 2019 08:22:41 +0000 (UTC)
Received: by smtp.codeaurora.org (Postfix, from userid 1000)
	id 5E1D7602F2; Tue, 10 Sep 2019 08:22:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1568103760;
	bh=iMsX33i5WoqjMwnnoNzhih2QRIUyQ3S/2okyWKG63c0=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=Wn/0wZXrgeScXoEeKRRe/p9awzoaaEbLmyiyfefGZUsBXwajp75DfQrs52edEOO5A
	 tnUZFHV8IKDD1Vpq+LnIzO6J3lzvxRsIpazd/qFX/0QGRlhDWU2zhqSXRsOBLT5vdL
	 4mQfhR+Q/Q4yaZ8Rmm3QREFhK/JeZbUE3yEvX7vg=
Received: from [10.204.83.131] (blr-c-bdr-fw-01_globalnat_allzones-outside.qualcomm.com [103.229.19.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: vinmenon@smtp.codeaurora.org)
	by smtp.codeaurora.org (Postfix) with ESMTPSA id B945F6050D;
	Tue, 10 Sep 2019 08:22:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1568103759;
	bh=iMsX33i5WoqjMwnnoNzhih2QRIUyQ3S/2okyWKG63c0=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=YFJuoKMoalsEfXezN78ZxCoaU5Hpzpa4pPgGCBQ+ywXcmRdvBQ7+6F9yLy0QIRw3C
	 ni/xMf6GEvMGK7yFMiN3h1HL9VPX9VmQhkPHAsBIrz/jPqoqNnNbAeKVIGpt/7uyZB
	 5DwHVviYZxDpc/tyHp3KR/f6jOvYI5xIevtEhOt0=
DMARC-Filter: OpenDMARC Filter v1.3.2 smtp.codeaurora.org B945F6050D
Authentication-Results: pdx-caf-mail.web.codeaurora.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: pdx-caf-mail.web.codeaurora.org; spf=none smtp.mailfrom=vinmenon@codeaurora.org
Subject: Re: [PATCH] mm: fix the race between swapin_readahead and
 SWP_SYNCHRONOUS_IO path
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org
References: <1567169011-4748-1-git-send-email-vinmenon@codeaurora.org>
 <20190909232613.GA39783@google.com>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <9df3bb51-2094-c849-8171-dce6784e1e70@codeaurora.org>
Date: Tue, 10 Sep 2019 13:52:36 +0530
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.9.0
MIME-Version: 1.0
In-Reply-To: <20190909232613.GA39783@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Minchan,


On 9/10/2019 4:56 AM, Minchan Kim wrote:
> Hi Vinayak,
>
> On Fri, Aug 30, 2019 at 06:13:31PM +0530, Vinayak Menon wrote:
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
>>
>> Fix this by reading the swap_count before lookup_swap_cache, which con=
forms
>> with the order in which page is added to swap cache and swap count is
>> decremented in do_swap_page. In the race case above, this will let Pb =
take
>> the readahead path and thus pick the proper page from swapcache.
> Thanks for the report, Vinayak.
>
> It's a zram specific issue because it deallocates zram block
> unconditionally once read IO is done. The expectation was that dirty
> page is on the swap cache but with SWP_SYNCHRONOUS_IO, it's not true
> any more so I want to resolve the issue in zram specific code, not
> general one.


Thanks for comments Minchan.

Trying to understand your comment better.=C2=A0 With SWP_SYNCHRONOUS_IO a=
lso, swap_slot_free_notify will

make sure that it deletes the entry only if the page is in swapcache. Eve=
n in the current issue case, a valid

entry is present in the swapcache at the time of issue (brought in by Pa)=
. Its just that Pb missed it due to the

race and tried to read again from zram. So thinking whether it is an issu=
e with zram deleting the entry, or

SWP_SYNCHRONOUS_IO failing to find the valid swapcache entry. There isn't=
 actually a case seen where zram

entry is deleted unconditionally, with some process yet to reference the =
slot and page is not in swapcache.


>
> A idea in my mind is swap_slot_free_notify should check the slot
> reference counter and if it's higher than 1, it shouldn't free the
> slot until. What do you think about?

It seems fine to me except for the fact that it will delay zram entry del=
etion for shared slots, which

can be significant sometimes. Also, should we fix this path as the issue =
is with SWP_SYNCHRONOUS_IO missing

a valid swapcache entry ?

Can swapcache check be done like below, before taking the SWP_SYNCHRONOUS=
_IO path, as an alternative ?


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
>> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
>> ---
>>  mm/memory.c | 21 ++++++++++++++++-----
>>  1 file changed, 16 insertions(+), 5 deletions(-)
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index e0c232f..22643aa 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -2744,6 +2744,8 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
>>  	struct page *page =3D NULL, *swapcache;
>>  	struct mem_cgroup *memcg;
>>  	swp_entry_t entry;
>> +	struct swap_info_struct *si;
>> +	bool skip_swapcache =3D false;
>>  	pte_t pte;
>>  	int locked;
>>  	int exclusive =3D 0;
>> @@ -2771,15 +2773,24 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
>> =20
>> =20
>>  	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
>> +
>> +	/*
>> +	 * lookup_swap_cache below can fail and before the SWP_SYNCHRONOUS_I=
O
>> +	 * check is made, another process can populate the swapcache, delete
>> +	 * the swap entry and decrement the swap count. So decide on taking
>> +	 * the SWP_SYNCHRONOUS_IO path before the lookup. In the event of th=
e
>> +	 * race described, the victim process will find a swap_count > 1
>> +	 * and can then take the readahead path instead of SWP_SYNCHRONOUS_I=
O.
>> +	 */
>> +	si =3D swp_swap_info(entry);
>> +	if (si->flags & SWP_SYNCHRONOUS_IO && __swap_count(entry) =3D=3D 1)
>> +		skip_swapcache =3D true;
>> +
>>  	page =3D lookup_swap_cache(entry, vma, vmf->address);
>>  	swapcache =3D page;
>> =20
>>  	if (!page) {
>> -		struct swap_info_struct *si =3D swp_swap_info(entry);
>> -
>> -		if (si->flags & SWP_SYNCHRONOUS_IO &&
>> -				__swap_count(entry) =3D=3D 1) {
>> -			/* skip swapcache */
>> +		if (skip_swapcache) {
>>  			page =3D alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma,
>>  							vmf->address);
>>  			if (page) {
>> --=20
>> QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
>> member of the Code Aurora Forum, hosted by The Linux Foundation
>>

