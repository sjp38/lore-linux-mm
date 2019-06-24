Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48811C48BE8
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 04:44:46 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 116AA213F2
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 04:44:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 116AA213F2
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B86206B0003; Mon, 24 Jun 2019 00:44:45 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B37558E0002; Mon, 24 Jun 2019 00:44:45 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9FFFA8E0001; Mon, 24 Jun 2019 00:44:45 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6AB0B6B0003
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 00:44:45 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id u21so8778133pfn.15
        for <linux-mm@kvack.org>; Sun, 23 Jun 2019 21:44:45 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:references:date:in-reply-to:message-id:user-agent
         :mime-version;
        bh=Ji8DNvujj/CEicTHVNU23bF98+MsaKG7wilSatCYpdY=;
        b=NU0ldZuo5KfFab5KRFmTDdk1mNFjHjfto6WCofLOAnQE7bQ066KRaItMUuZ0CVsZZU
         EOKfhxYq7mVNfgXo/4XadjkqAfZnxIwV/aNFGVsAa2DB7qlGRxOfK25NerASYbEBHGKS
         b1Jgoat/wwSvAcKEYy/+ocNpv9uhj6FEmlu0xs8/P1x8doJ29c+mLMl5BXqvP7LvY7hh
         ORw6rsZtGssSMdfEYXv5fetGih5pkHToqTaeYtu8eUBQdk15/p1kj9k/Ug3ii5QTZihg
         YgCyaFJN+BKfb+lXIjLxo2mehnCFjvQ2eSh0wzJxlEAnjqzmQpZYp4Srzkuly9ddtbKZ
         64EA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ying.huang@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAVIBnRngIGavowneHn7GfQ4oms7GbO2jlxd/EBTykmtAT1YRuO+
	yRsj/ZfUwde9UNoQqC0XaIMH73bS8i/em2ULvKMas+yN1TMrGVDM8wxMDals+1I3aQADjn8Dp06
	ceDQfuCJS3bWhqz+OBZZu089VtPsgOz2xXhwPAOvyWH77Q2mqMkJOgGVAhKKr/rHeVg==
X-Received: by 2002:a17:902:7448:: with SMTP id e8mr137082048plt.222.1561351485120;
        Sun, 23 Jun 2019 21:44:45 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzYy9aZF5pETS39ql3XQsGc46Uy5cl+pCgKZ8R4SdyrKwiTG9F9pei+Jw1+ClXcgIvsK/qF
X-Received: by 2002:a17:902:7448:: with SMTP id e8mr137082012plt.222.1561351484453;
        Sun, 23 Jun 2019 21:44:44 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561351484; cv=none;
        d=google.com; s=arc-20160816;
        b=Jdq7PLsnzhBm7R4hWvxOH5avMl0mtUzrX3pVyz4Y81/6Qq7Y0Zdk8cIjjx7pn9guZJ
         jeLT6hE2r6ATuVTKll8tJa1Dav9VaIFjI+BgVUQ2iQAfQRzH/7FDd+E4smMLkaVquQYD
         yRkGRBbQz4qBZrLnDygSLToIPgOsb4y9VzilnM3XeSzKDPD5995zKGTK2o5ViCCNx8bM
         mhUf4hhdm8Wwic3y03OcpF+m9TmbXUcSbVbs+2roGfgy8uZ/DZrSh0gi3MjvUqwtLccA
         pXbRcz73No35ldAkCzm1ZNQg9q+Wo3wD8rZGysjp5TngJmoLWBOL6tIpf19WM0wvnHCV
         tyMQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:user-agent:message-id:in-reply-to:date:references
         :subject:cc:to:from;
        bh=Ji8DNvujj/CEicTHVNU23bF98+MsaKG7wilSatCYpdY=;
        b=GAzWTdnZtakSQ3jJ56dYNStPzBY6825fcIdpYN/bEXqJXsmkaSGwRxb8eKr4VV0kHf
         6VLWx4YckZ0PcQmidaWZYr0tzi2TRoxJ8LOJQR7Vg5TIYGs5oIk4B6Z47LyO8fYv/ILb
         5RQsLGNaHRmq3XEdzuo7CKO97NiN4zpcCVdFMckbvpA6mx/XfBiE8q1+//v91MfbGHZn
         Lbo4mcio2ec2bsGXhF680COEN36H1QXQqi2JN4uV9yIIvRrPHCkoDHEqpeMinySWuRgR
         xEVSz7HH/G80qyV3VpaBmym2AiWHw2uzRgr+gw4AuKHXnRlFDaF5yVO5ZXGHTu84/Ob/
         CEKA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id f32si10089909pjg.42.2019.06.23.21.44.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 23 Jun 2019 21:44:44 -0700 (PDT)
Received-SPF: pass (google.com: domain of ying.huang@intel.com designates 192.55.52.93 as permitted sender) client-ip=192.55.52.93;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ying.huang@intel.com designates 192.55.52.93 as permitted sender) smtp.mailfrom=ying.huang@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga001.jf.intel.com ([10.7.209.18])
  by fmsmga102.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 23 Jun 2019 21:44:43 -0700
X-ExtLoop1: 1
X-IronPort-AV: E=Sophos;i="5.63,411,1557212400"; 
   d="scan'208";a="244579823"
Received: from yhuang-dev.sh.intel.com (HELO yhuang-dev) ([10.239.159.29])
  by orsmga001.jf.intel.com with ESMTP; 23 Jun 2019 21:44:41 -0700
From: "Huang\, Ying" <ying.huang@intel.com>
To: Ming Lei <ming.lei@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,  <linux-mm@kvack.org>,  <linux-kernel@vger.kernel.org>,  Michal Hocko <mhocko@kernel.org>,  "Johannes Weiner" <hannes@cmpxchg.org>,  Hugh Dickins <hughd@google.com>,  Minchan Kim <minchan@kernel.org>,  Rik van Riel <riel@redhat.com>,  Daniel Jordan <daniel.m.jordan@oracle.com>
Subject: Re: [PATCH -mm] mm, swap: Fix THP swap out
References: <20190624022336.12465-1-ying.huang@intel.com>
	<20190624033438.GB6563@ming.t460p>
Date: Mon, 24 Jun 2019 12:44:41 +0800
In-Reply-To: <20190624033438.GB6563@ming.t460p> (Ming Lei's message of "Mon,
	24 Jun 2019 11:34:40 +0800")
Message-ID: <87imsvbnie.fsf@yhuang-dev.intel.com>
User-Agent: Gnus/5.13 (Gnus v5.13) Emacs/26.1 (gnu/linux)
MIME-Version: 1.0
Content-Type: text/plain; charset=ascii
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Ming Lei <ming.lei@redhat.com> writes:

> Hi Huang Ying,
>
> On Mon, Jun 24, 2019 at 10:23:36AM +0800, Huang, Ying wrote:
>> From: Huang Ying <ying.huang@intel.com>
>> 
>> 0-Day test system reported some OOM regressions for several
>> THP (Transparent Huge Page) swap test cases.  These regressions are
>> bisected to 6861428921b5 ("block: always define BIO_MAX_PAGES as
>> 256").  In the commit, BIO_MAX_PAGES is set to 256 even when THP swap
>> is enabled.  So the bio_alloc(gfp_flags, 512) in get_swap_bio() may
>> fail when swapping out THP.  That causes the OOM.
>> 
>> As in the patch description of 6861428921b5 ("block: always define
>> BIO_MAX_PAGES as 256"), THP swap should use multi-page bvec to write
>> THP to swap space.  So the issue is fixed via doing that in
>> get_swap_bio().
>> 
>> BTW: I remember I have checked the THP swap code when
>> 6861428921b5 ("block: always define BIO_MAX_PAGES as 256") was merged,
>> and thought the THP swap code needn't to be changed.  But apparently,
>> I was wrong.  I should have done this at that time.
>> 
>> Fixes: 6861428921b5 ("block: always define BIO_MAX_PAGES as 256")
>> Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
>> Cc: Ming Lei <ming.lei@redhat.com>
>> Cc: Michal Hocko <mhocko@kernel.org>
>> Cc: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Hugh Dickins <hughd@google.com>
>> Cc: Minchan Kim <minchan@kernel.org>
>> Cc: Rik van Riel <riel@redhat.com>
>> Cc: Daniel Jordan <daniel.m.jordan@oracle.com>
>> ---
>>  mm/page_io.c | 7 ++-----
>>  1 file changed, 2 insertions(+), 5 deletions(-)
>> 
>> diff --git a/mm/page_io.c b/mm/page_io.c
>> index 2e8019d0e048..4ab997f84061 100644
>> --- a/mm/page_io.c
>> +++ b/mm/page_io.c
>> @@ -29,10 +29,9 @@
>>  static struct bio *get_swap_bio(gfp_t gfp_flags,
>>  				struct page *page, bio_end_io_t end_io)
>>  {
>> -	int i, nr = hpage_nr_pages(page);
>>  	struct bio *bio;
>>  
>> -	bio = bio_alloc(gfp_flags, nr);
>> +	bio = bio_alloc(gfp_flags, 1);
>>  	if (bio) {
>>  		struct block_device *bdev;
>>  
>> @@ -41,9 +40,7 @@ static struct bio *get_swap_bio(gfp_t gfp_flags,
>>  		bio->bi_iter.bi_sector <<= PAGE_SHIFT - 9;
>>  		bio->bi_end_io = end_io;
>>  
>> -		for (i = 0; i < nr; i++)
>> -			bio_add_page(bio, page + i, PAGE_SIZE, 0);
>
> bio_add_page() supposes to work, just wondering why it doesn't recently.

Yes.  Just checked and bio_add_page() works too.  I should have used
that.  The problem isn't bio_add_page(), but bio_alloc(), because nr ==
512 > 256, mempool cannot be used during swapout, so swapout will fail.

Best Regards,
Huang, Ying

> Could you share me one test case for reproducing it?
>
>> -		VM_BUG_ON(bio->bi_iter.bi_size != PAGE_SIZE * nr);
>> +		__bio_add_page(bio, page, PAGE_SIZE * hpage_nr_pages(page), 0);
>>  	}
>>  	return bio;
>
> Actually the above code can be simplified as:
>
> diff --git a/mm/page_io.c b/mm/page_io.c
> index 2e8019d0e048..c20b4189d0a1 100644
> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -29,7 +29,7 @@
>  static struct bio *get_swap_bio(gfp_t gfp_flags,
>  				struct page *page, bio_end_io_t end_io)
>  {
> -	int i, nr = hpage_nr_pages(page);
> +	int nr = hpage_nr_pages(page);
>  	struct bio *bio;
>  
>  	bio = bio_alloc(gfp_flags, nr);
> @@ -41,8 +41,7 @@ static struct bio *get_swap_bio(gfp_t gfp_flags,
>  		bio->bi_iter.bi_sector <<= PAGE_SHIFT - 9;
>  		bio->bi_end_io = end_io;
>  
> -		for (i = 0; i < nr; i++)
> -			bio_add_page(bio, page + i, PAGE_SIZE, 0);
> +		bio_add_page(bio, page, PAGE_SIZE * nr, 0);
>  		VM_BUG_ON(bio->bi_iter.bi_size != PAGE_SIZE * nr);
>  	}
>  	return bio;
>
>
> Thanks,
> Ming

