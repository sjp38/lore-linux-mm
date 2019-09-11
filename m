Return-Path: <SRS0=IwQ2=XG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 79F07C5ACAE
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 10:07:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2C90420863
	for <linux-mm@archiver.kernel.org>; Wed, 11 Sep 2019 10:07:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="He2UcUFM";
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="TUQMPWQo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2C90420863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A8C226B0005; Wed, 11 Sep 2019 06:07:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A3D526B0006; Wed, 11 Sep 2019 06:07:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 904866B0007; Wed, 11 Sep 2019 06:07:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0103.hostedemail.com [216.40.44.103])
	by kanga.kvack.org (Postfix) with ESMTP id 6EE506B0005
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 06:07:31 -0400 (EDT)
Received: from smtpin14.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay04.hostedemail.com (Postfix) with SMTP id 1524D55F86
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 10:07:31 +0000 (UTC)
X-FDA: 75922212702.14.magic10_4186eb9dd7519
X-HE-Tag: magic10_4186eb9dd7519
X-Filterd-Recvd-Size: 12500
Received: from smtp.codeaurora.org (smtp.codeaurora.org [198.145.29.96])
	by imf47.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 11 Sep 2019 10:07:30 +0000 (UTC)
Received: by smtp.codeaurora.org (Postfix, from userid 1000)
	id 0183361639; Wed, 11 Sep 2019 10:07:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1568196449;
	bh=NdodhfT5XkCJLJH9AVgYeVJpLl4mxbVl1ejgiPReWEQ=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=He2UcUFMzgwj0Inwwn6XiIe38EXpcyHE/9CUSTsYAPZxvxsKekeY9WeVehkPx5vAh
	 CoXCkdNe7cHXgBVa001VnGk0CEAAySYg3fKJFdN/hJ0x4p3plR00kPQFt5G5V8CftR
	 mzOEmURHNgRzHF2YKqqx/uhqmh9r3Zk6zT3qrRxE=
Received: from [10.204.83.131] (blr-c-bdr-fw-01_globalnat_allzones-outside.qualcomm.com [103.229.19.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: vinmenon@smtp.codeaurora.org)
	by smtp.codeaurora.org (Postfix) with ESMTPSA id 9CC2761570;
	Wed, 11 Sep 2019 10:07:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1568196447;
	bh=NdodhfT5XkCJLJH9AVgYeVJpLl4mxbVl1ejgiPReWEQ=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=TUQMPWQoH/2hBBqfj1hyO+1L53YCt3l6y3XZmL5KgzE4jHP85ex0Ip52crBNe7UWL
	 K7wzMM8tqayRS3HrhqyhkqWh4drU5Kf55Cq6T1C2XH63dVABjbwjT1J9h86Yr/D3CC
	 G4oGPkvKediTxSgEgvHciLfYY1KX5yhTIDObKAZU=
DMARC-Filter: OpenDMARC Filter v1.3.2 smtp.codeaurora.org 9CC2761570
Authentication-Results: pdx-caf-mail.web.codeaurora.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: pdx-caf-mail.web.codeaurora.org; spf=none smtp.mailfrom=vinmenon@codeaurora.org
Subject: Re: [PATCH] mm: fix the race between swapin_readahead and
 SWP_SYNCHRONOUS_IO path
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org
References: <1567169011-4748-1-git-send-email-vinmenon@codeaurora.org>
 <20190909232613.GA39783@google.com>
 <9df3bb51-2094-c849-8171-dce6784e1e70@codeaurora.org>
 <20190910175116.GB39783@google.com>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <c7fbc609-0bb0-bffd-8b1f-c2588c89bfd2@codeaurora.org>
Date: Wed, 11 Sep 2019 15:37:23 +0530
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.9.0
MIME-Version: 1.0
In-Reply-To: <20190910175116.GB39783@google.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 9/10/2019 11:21 PM, Minchan Kim wrote:
> On Tue, Sep 10, 2019 at 01:52:36PM +0530, Vinayak Menon wrote:
>> Hi Minchan,
>>
>>
>> On 9/10/2019 4:56 AM, Minchan Kim wrote:
>>> Hi Vinayak,
>>>
>>> On Fri, Aug 30, 2019 at 06:13:31PM +0530, Vinayak Menon wrote:
>>>> The following race is observed due to which a processes faulting
>>>> on a swap entry, finds the page neither in swapcache nor swap. This
>>>> causes zram to give a zero filled page that gets mapped to the
>>>> process, resulting in a user space crash later.
>>>>
>>>> Consider parent and child processes Pa and Pb sharing the same swap
>>>> slot with swap_count 2. Swap is on zram with SWP_SYNCHRONOUS_IO set.
>>>> Virtual address 'VA' of Pa and Pb points to the shared swap entry.
>>>>
>>>> Pa                                       Pb
>>>>
>>>> fault on VA                              fault on VA
>>>> do_swap_page                             do_swap_page
>>>> lookup_swap_cache fails                  lookup_swap_cache fails
>>>>                                          Pb scheduled out
>>>> swapin_readahead (deletes zram entry)
>>>> swap_free (makes swap_count 1)
>>>>                                          Pb scheduled in
>>>>                                          swap_readpage (swap_count =3D=
=3D 1)
>>>>                                          Takes SWP_SYNCHRONOUS_IO pa=
th
>>>>                                          zram enrty absent
>>>>                                          zram gives a zero filled pa=
ge
>>>>
>>>> Fix this by reading the swap_count before lookup_swap_cache, which c=
onforms
>>>> with the order in which page is added to swap cache and swap count i=
s
>>>> decremented in do_swap_page. In the race case above, this will let P=
b take
>>>> the readahead path and thus pick the proper page from swapcache.
>>> Thanks for the report, Vinayak.
>>>
>>> It's a zram specific issue because it deallocates zram block
>>> unconditionally once read IO is done. The expectation was that dirty
>>> page is on the swap cache but with SWP_SYNCHRONOUS_IO, it's not true
>>> any more so I want to resolve the issue in zram specific code, not
>>> general one.
>>
>> Thanks for comments Minchan.
>>
>> Trying to understand your comment better.=C2=A0 With SWP_SYNCHRONOUS_I=
O also, swap_slot_free_notify will
>>
>> make sure that it deletes the entry only if the page is in swapcache. =
Even in the current issue case, a valid
>>
>> entry is present in the swapcache at the time of issue (brought in by =
Pa). Its just that Pb missed it due to the
>>
>> race and tried to read again from zram. So thinking whether it is an i=
ssue with zram deleting the entry, or
>>
>> SWP_SYNCHRONOUS_IO failing to find the valid swapcache entry. There is=
n't actually a case seen where zram
>>
>> entry is deleted unconditionally, with some process yet to reference t=
he slot and page is not in swapcache.
>>
>>
>>> A idea in my mind is swap_slot_free_notify should check the slot
>>> reference counter and if it's higher than 1, it shouldn't free the
>>> slot until. What do you think about?
>> It seems fine to me except for the fact that it will delay zram entry =
deletion for shared slots, which
>>
>> can be significant sometimes. Also, should we fix this path as the iss=
ue is with SWP_SYNCHRONOUS_IO missing
> It's always trade-off between memory vs performance since it could hit
> in swap cache. If it's shared page, it's likely to hit a cache next tim=
e
> so we could get performance benefit.
>
> Actually, swap_slot_free_notify is layering violation so I wanted to
> replace it with discard hint in the long run so want to go the directio=
n.


Okay got it.


>
>> a valid swapcache entry ?
>>
>> Can swapcache check be done like below, before taking the SWP_SYNCHRON=
OUS_IO path, as an alternative ?
> With your approach, what prevent below scenario?
>
> A                                                       B
>
>                                             do_swap_page
>                                             SWP_SYNCHRONOUS_IO && __swa=
p_count =3D=3D 1


As shrink_page_list is picking the page from LRU and B is trying to read =
from swap simultaneously, I assume someone had read

the page from swap prior to B, when its swap_count was say 2 (for it to b=
e reclaimed by shrink_page_list now)

If so, that read itself would have deleted the zram entry ? And the read =
page will be in swapcache and dirty ? In that case, with SWAP_HAS_CACHE

check in the patch, B will take readahead path. And shrink_page_list woul=
d attempt a pageout to zram, for the dirty page ?


> shrink_page_list
> add_to_swap
>     swap_count =3D 2
>
> ..
> ..
> do_swap_page
> swap_read
>     swap_slot_free_notify
>         zram's slot will be removed
>                                             page =3D alloc_page_vma
>                                             swap_readpage <-- read zero
>
>
>>
>> diff --git a/include/linux/swap.h b/include/linux/swap.h
>> index 063c0c1..a5ca05f 100644
>> --- a/include/linux/swap.h
>> +++ b/include/linux/swap.h
>> @@ -463,6 +463,7 @@ extern sector_t map_swap_page(struct page *, struc=
t block_device **);
>> =C2=A0extern sector_t swapdev_block(int, pgoff_t);
>> =C2=A0extern int page_swapcount(struct page *);
>> =C2=A0extern int __swap_count(swp_entry_t entry);
>> +extern bool __swap_has_cache(swp_entry_t entry);
>> =C2=A0extern int __swp_swapcount(swp_entry_t entry);
>> =C2=A0extern int swp_swapcount(swp_entry_t entry);
>> =C2=A0extern struct swap_info_struct *page_swap_info(struct page *);
>> @@ -589,6 +590,11 @@ static inline int __swap_count(swp_entry_t entry)
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return 0;
>> =C2=A0}
>>
>> +static bool __swap_has_cache(swp_entry_t entry)
>> +{
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return 0;
>> +}
>> +
>> =C2=A0static inline int __swp_swapcount(swp_entry_t entry)
>> =C2=A0{
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return 0;
>>
>> diff --git a/mm/memory.c b/mm/memory.c
>> index e0c232f..a13511f 100644
>> --- a/mm/memory.c
>> +++ b/mm/memory.c
>> @@ -2778,7 +2778,8 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 struct swap_info_struct *si =3D swp_swap_info(entry);
>>
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 if (si->flags & SWP_SYNCHRONOUS_IO &&
>> -=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 __swap_count(entry) =3D=3D 1) {
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 __swap_count(entry) =3D=3D 1 &&
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 !__swap_has_cache(entry)) {
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 /* ski=
p swapcache */
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 page =3D=
 alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma,
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 vmf->address);
>> diff --git a/mm/swapfile.c b/mm/swapfile.c
>> index 80445f4..2a1554a8 100644
>> --- a/mm/swapfile.c
>> +++ b/mm/swapfile.c
>> @@ -1459,6 +1459,20 @@ int __swap_count(swp_entry_t entry)
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return count;
>> =C2=A0}
>>
>> +bool __swap_has_cache(swp_entry_t entry)
>> +{
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 struct swap_info_struct *si;
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 pgoff_t offset =3D swp_offset(en=
try);
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 bool has_cache=C2=A0 =3D false;
>> +
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 si =3D get_swap_device(entry);
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (si) {
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0 has_cache =3D !!(si->swap_map[offset] & SWAP_HAS_CACHE);
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0 put_swap_device(si);
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 }
>> +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 return has_cache;
>> +}
>> +
>> =C2=A0static int swap_swapcount(struct swap_info_struct *si, swp_entry=
_t entry)
>> =C2=A0{
>> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 int count =3D 0;
>>
>>
>>>> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
>>>> ---
>>>>  mm/memory.c | 21 ++++++++++++++++-----
>>>>  1 file changed, 16 insertions(+), 5 deletions(-)
>>>>
>>>> diff --git a/mm/memory.c b/mm/memory.c
>>>> index e0c232f..22643aa 100644
>>>> --- a/mm/memory.c
>>>> +++ b/mm/memory.c
>>>> @@ -2744,6 +2744,8 @@ vm_fault_t do_swap_page(struct vm_fault *vmf)
>>>>  	struct page *page =3D NULL, *swapcache;
>>>>  	struct mem_cgroup *memcg;
>>>>  	swp_entry_t entry;
>>>> +	struct swap_info_struct *si;
>>>> +	bool skip_swapcache =3D false;
>>>>  	pte_t pte;
>>>>  	int locked;
>>>>  	int exclusive =3D 0;
>>>> @@ -2771,15 +2773,24 @@ vm_fault_t do_swap_page(struct vm_fault *vmf=
)
>>>> =20
>>>> =20
>>>>  	delayacct_set_flag(DELAYACCT_PF_SWAPIN);
>>>> +
>>>> +	/*
>>>> +	 * lookup_swap_cache below can fail and before the SWP_SYNCHRONOUS=
_IO
>>>> +	 * check is made, another process can populate the swapcache, dele=
te
>>>> +	 * the swap entry and decrement the swap count. So decide on takin=
g
>>>> +	 * the SWP_SYNCHRONOUS_IO path before the lookup. In the event of =
the
>>>> +	 * race described, the victim process will find a swap_count > 1
>>>> +	 * and can then take the readahead path instead of SWP_SYNCHRONOUS=
_IO.
>>>> +	 */
>>>> +	si =3D swp_swap_info(entry);
>>>> +	if (si->flags & SWP_SYNCHRONOUS_IO && __swap_count(entry) =3D=3D 1=
)
>>>> +		skip_swapcache =3D true;
>>>> +
>>>>  	page =3D lookup_swap_cache(entry, vma, vmf->address);
>>>>  	swapcache =3D page;
>>>> =20
>>>>  	if (!page) {
>>>> -		struct swap_info_struct *si =3D swp_swap_info(entry);
>>>> -
>>>> -		if (si->flags & SWP_SYNCHRONOUS_IO &&
>>>> -				__swap_count(entry) =3D=3D 1) {
>>>> -			/* skip swapcache */
>>>> +		if (skip_swapcache) {
>>>>  			page =3D alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma,
>>>>  							vmf->address);
>>>>  			if (page) {
>>>> --=20
>>>> QUALCOMM INDIA, on behalf of Qualcomm Innovation Center, Inc. is a
>>>> member of the Code Aurora Forum, hosted by The Linux Foundation
>>>>

