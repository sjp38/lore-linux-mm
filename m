Return-Path: <SRS0=NQQQ=W6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.1 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2BA4EC3A5A2
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 12:17:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B64D8208E4
	for <linux-mm@archiver.kernel.org>; Tue,  3 Sep 2019 12:17:29 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="MFgUxHvS";
	dkim=fail reason="key not found in DNS" (0-bit key) header.d=codeaurora.org header.i=@codeaurora.org header.b="MFgUxHvS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B64D8208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 43D156B0003; Tue,  3 Sep 2019 08:17:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3ED8E6B0005; Tue,  3 Sep 2019 08:17:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2DB8F6B0006; Tue,  3 Sep 2019 08:17:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0152.hostedemail.com [216.40.44.152])
	by kanga.kvack.org (Postfix) with ESMTP id 07AFC6B0003
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 08:17:28 -0400 (EDT)
Received: from smtpin22.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay01.hostedemail.com (Postfix) with SMTP id 9D697180AD7C3
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 12:17:28 +0000 (UTC)
X-FDA: 75893509776.22.debt97_6ffde121310e
X-HE-Tag: debt97_6ffde121310e
X-Filterd-Recvd-Size: 5657
Received: from smtp.codeaurora.org (smtp.codeaurora.org [198.145.29.96])
	by imf33.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Tue,  3 Sep 2019 12:17:27 +0000 (UTC)
Received: by smtp.codeaurora.org (Postfix, from userid 1000)
	id DEA6B6013C; Tue,  3 Sep 2019 12:17:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1567513046;
	bh=gjQT1cxFHMrKIOFm3LdbjeSyPHbROd7jQFBmMgfduNU=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=MFgUxHvSCFWSZBkguO/hQFA6FEPUA7L+xhKd93jVN/mLmGFuESmzSQRhPAm39FZh/
	 phcOh7agGlxnYO8x7GHQx04uRCcfHNLVQYdnawSUd3gisfeOnspjrIw66O+t+aQjTj
	 uYUMDC1IFzkaAKb4M0HPgcKwcOOKvFNrwEILX5L4=
Received: from [10.204.83.131] (blr-c-bdr-fw-01_globalnat_allzones-outside.qualcomm.com [103.229.19.19])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: vinmenon@smtp.codeaurora.org)
	by smtp.codeaurora.org (Postfix) with ESMTPSA id 4F98E60213;
	Tue,  3 Sep 2019 12:17:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=codeaurora.org;
	s=default; t=1567513046;
	bh=gjQT1cxFHMrKIOFm3LdbjeSyPHbROd7jQFBmMgfduNU=;
	h=Subject:To:Cc:References:From:Date:In-Reply-To:From;
	b=MFgUxHvSCFWSZBkguO/hQFA6FEPUA7L+xhKd93jVN/mLmGFuESmzSQRhPAm39FZh/
	 phcOh7agGlxnYO8x7GHQx04uRCcfHNLVQYdnawSUd3gisfeOnspjrIw66O+t+aQjTj
	 uYUMDC1IFzkaAKb4M0HPgcKwcOOKvFNrwEILX5L4=
DMARC-Filter: OpenDMARC Filter v1.3.2 smtp.codeaurora.org 4F98E60213
Authentication-Results: pdx-caf-mail.web.codeaurora.org; dmarc=none (p=none dis=none) header.from=codeaurora.org
Authentication-Results: pdx-caf-mail.web.codeaurora.org; spf=none smtp.mailfrom=vinmenon@codeaurora.org
Subject: Re: [PATCH] mm: fix the race between swapin_readahead and
 SWP_SYNCHRONOUS_IO path
To: Michal Hocko <mhocko@kernel.org>
Cc: minchan@kernel.org, linux-mm@kvack.org
References: <1567169011-4748-1-git-send-email-vinmenon@codeaurora.org>
 <20190902132104.GJ14028@dhcp22.suse.cz>
 <79303914-d6a6-011a-150f-74488c8e12f2@codeaurora.org>
 <20190903114109.GR14028@dhcp22.suse.cz>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <07f908cb-af0d-0688-ad8b-d709c7d5691d@codeaurora.org>
Date: Tue, 3 Sep 2019 17:47:22 +0530
User-Agent: Mozilla/5.0 (Windows NT 10.0; WOW64; rv:60.0) Gecko/20100101
 Thunderbird/60.8.0
MIME-Version: 1.0
In-Reply-To: <20190903114109.GR14028@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>


On 9/3/2019 5:11 PM, Michal Hocko wrote:
> On Tue 03-09-19 11:43:16, Vinayak Menon wrote:
>> Hi Michal,
>>
>> Thanks for reviewing this.
>>
>>
>> On 9/2/2019 6:51 PM, Michal Hocko wrote:
>>> On Fri 30-08-19 18:13:31, Vinayak Menon wrote:
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
>>>>                                          swap_readpage (swap_count == 1)
>>>>                                          Takes SWP_SYNCHRONOUS_IO path
>>>>                                          zram enrty absent
>>>>                                          zram gives a zero filled page
>>> This sounds like a zram issue, right? Why is a generic swap path changed
>>> then?
>>
>> I think zram entry being deleted by Pa and zram giving out a zeroed page to Pb is normal.
> Isn't that a data loss? The race you mentioned shouldn't be possible
> with the standard swap storage AFAIU. If that is really the case then
> the zram needs a fix rather than a generic path. Or at least a very good
> explanation why the generic path is a preferred way.


AFAIK, there isn't a data loss because, before deleting the entry, swap_slot_free_notify makes sure that

page is in swapcache and marks the page dirty to ensure a swap out before reclaim. I am referring to the

comment about this in swap_slot_free_notify. In the case of this race too, the page brought to swapcache

by Pa is still in swapcache. It is just that Pb failed to find it due to the race.

Yes, this race will not happen for standard swap storage and only for those block devices that set

disk->fops->swap_slot_free_notify and have SWP_SYNCHRONOUS_IO set (which seems to be only zram).

Now considering that zram works as expected, the fix is in generic path because the race is due to the bug in

SWP_SYNCHRONOUS_IO handling in do_swap_page. And it is only the SWP_SYNCHRONOUS_IO handling in

generic path which is modified.



