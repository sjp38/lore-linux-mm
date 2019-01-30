Return-Path: <SRS0=ywda=QG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75BC7C282C7
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 00:24:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2F0CF21848
	for <linux-mm@archiver.kernel.org>; Wed, 30 Jan 2019 00:24:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="jmp5v6OD"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2F0CF21848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C282A8E0005; Tue, 29 Jan 2019 19:23:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C07C98E0001; Tue, 29 Jan 2019 19:23:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B12BA8E0005; Tue, 29 Jan 2019 19:23:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6B4C08E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 19:23:59 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id r16so15084681pgr.15
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 16:23:59 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=EegVelnyvrKDkR5jEv97mZvgbmU9h9IG3+6MUWPsjeI=;
        b=jbIXk0h0J9XvG6nNBLLCbMcGSYDidGoY1rbsU7R9JaccONbvgNW4eZ+U752lsLf7Rv
         q9hWvSbIXn9CSPybTqrvKMQ+VDp7Xj5UVrM4mz81PQnZ/N/D48nQxzBpNspysjrgd5La
         KzbN8RQ/SGC1Nwh5s3Bml21SgRfOi8Z4d0/dNjj5Wok7Lt2FEeidnPeWAxAgGdLSI6zB
         /0qfCXawBIN5nwP4QpZ3S3loZIUC27YfvZbcpT3PUoPR0Y+Q/tTIhcsCKiw0pSZwI/TE
         MI3Pv03+/wcQ1n6BTqi8oFm69qC+mXXIIlPw49YUHdxDfp3LLxKFiVMgP870sYqxWn/u
         Pt1g==
X-Gm-Message-State: AJcUukdmhrDnWMTqesfPtWowwQYIH2mP0U7uX66jtev6jjwZ7hxpHl44
	hKd/fYQPXVjTii00r5jRGH9SWDHwSP741ps29w5sOQ5+Wg0biEQbNsSVbvQ2cQBJXqTqKi7COmz
	HXniXAViVV+oPhe6rO6aFM2JepKzhFCAh4tAkiPVelM4YICov3XOY80HWz2RDagJFlQ==
X-Received: by 2002:a65:4049:: with SMTP id h9mr25200195pgp.304.1548807838989;
        Tue, 29 Jan 2019 16:23:58 -0800 (PST)
X-Google-Smtp-Source: ALg8bN51lHVb5oqjfG3YW12tb8wt9mqkHExmclNQrikb+ORj50o+SRwN2nSB9Cdv0vQulqAsPJ5z
X-Received: by 2002:a65:4049:: with SMTP id h9mr25200162pgp.304.1548807838257;
        Tue, 29 Jan 2019 16:23:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548807838; cv=none;
        d=google.com; s=arc-20160816;
        b=bJc50feURP9CHixYR3BY+2qX/UKtRf50TQRmnnaDJYXhPw4ODg6369yeNaldHAwuBm
         iC0VJAzheEw+x3jt2v2ydQEtfMwahg6NcvXKj/JvJCDPqvzYVZM1o6a3WhfdXwESs+/l
         J7Fw3EgmI1L7+qogUpRGlUO8yzEbWJvjHnau8xpbeFpX4CKRRA0+4BBY9KY9S1iHPkf5
         dlRwSGVRt4jV/5rPUyPNZR1F+rftpRQxuLl1h92cU046jpudgdJWBNSSk6VWvQeI7e0M
         ogsTtMnYEQdsIcYVMplY3M6tjM8oDlqxjPA5Hf/rx75ZYPMZaH8SZ/j4cjqMwbPZkmpg
         SKtA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=EegVelnyvrKDkR5jEv97mZvgbmU9h9IG3+6MUWPsjeI=;
        b=OVSQAbYLyk5BGRoRJukJ+IXMTdDfqFNB8yhu10kU/beELE+x0Im5RxZQwGlpFENyOK
         eW5E4ZeYkmGnAsm/K2POnrnmFJWQ2J6UBaJHw54kMllKuZ+vS43XAQTSaHt215lUfUQc
         /3Ect6fBruTWoRWU2+183HcmZMFEoRoWmX4zVHA1ETgBJklUYMNKBBs9xeC41rutogwH
         3+G9xUlp0Al8K+YbRV8GA0wXmHgm0dgSTvsG9V1mFywyZsRJQoNUzqvzMwKkxhWDcBSq
         YL22mBA7CxoBgN5rL2VVoXq0+kc+DgtxAJBIY1ZfARmNE5ZFFZ+dDr8EcSfynY61Wgjg
         /hmA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=jmp5v6OD;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id a24si37520687pgd.248.2019.01.29.16.23.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 16:23:58 -0800 (PST)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=jmp5v6OD;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from localhost (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8A7F820881;
	Wed, 30 Jan 2019 00:23:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1548807837;
	bh=uRNu24/8CQ88tUh3cvXgGy7RgmiCGkf93XVlmmgKdmw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=jmp5v6ODdLkL2P+d3BycB5vJN3owR2gpeSZqp35VIljUJF93dAhsvh5wR3Erknh5f
	 zwvgdhA+nsU8OnQk1o3ic48FpbqlBJ6s0g+SKea2oZ4qHUnYkNIg7PqOvpPJZ7Bhes
	 +C6MmCrgjD7Fwq7JfXiKNxxPzINlwiJ9cr0ao9u8=
Date: Tue, 29 Jan 2019 19:23:56 -0500
From: Sasha Levin <sashal@kernel.org>
To: Greg KH <greg@kroah.com>
Cc: Michal Hocko <mhocko@kernel.org>, Roman Gushchin <guro@fb.com>,
	Dexuan Cui <decui@microsoft.com>,
	"linux-mm@kvack.org" <linux-mm@kvack.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Kernel Team <Kernel-team@fb.com>,
	Shakeel Butt <shakeelb@google.com>,
	Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>,
	Rik van Riel <riel@surriel.com>,
	Konstantin Khlebnikov <koct9i@gmail.com>,
	Matthew Wilcox <willy@infradead.org>,
	"Stable@vger.kernel.org" <Stable@vger.kernel.org>
Subject: Re: Will the recent memory leak fixes be backported to longterm
 kernels?
Message-ID: <20190130002356.GQ3973@sasha-vm>
References: <20181102073009.GP23921@dhcp22.suse.cz>
 <20181102154844.GA17619@tower.DHCP.thefacebook.com>
 <20181102161314.GF28039@dhcp22.suse.cz>
 <20181102162237.GB17619@tower.DHCP.thefacebook.com>
 <20181102165147.GG28039@dhcp22.suse.cz>
 <20181102172547.GA19042@tower.DHCP.thefacebook.com>
 <20181102174823.GI28039@dhcp22.suse.cz>
 <20181102193827.GA18024@castle.DHCP.thefacebook.com>
 <20181105092053.GC4361@dhcp22.suse.cz>
 <20181228105008.GB15967@kroah.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20181228105008.GB15967@kroah.com>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Dec 28, 2018 at 11:50:08AM +0100, Greg KH wrote:
>On Mon, Nov 05, 2018 at 10:21:23AM +0100, Michal Hocko wrote:
>> On Fri 02-11-18 19:38:35, Roman Gushchin wrote:
>> > On Fri, Nov 02, 2018 at 06:48:23PM +0100, Michal Hocko wrote:
>> > > On Fri 02-11-18 17:25:58, Roman Gushchin wrote:
>> > > > On Fri, Nov 02, 2018 at 05:51:47PM +0100, Michal Hocko wrote:
>> > > > > On Fri 02-11-18 16:22:41, Roman Gushchin wrote:
>> > > [...]
>> > > > > > 2) We do forget to scan the last page in the LRU list. So if we ended up with
>> > > > > > 1-page long LRU, it can stay there basically forever.
>> > > > >
>> > > > > Why
>> > > > > 		/*
>> > > > > 		 * If the cgroup's already been deleted, make sure to
>> > > > > 		 * scrape out the remaining cache.
>> > > > > 		 */
>> > > > > 		if (!scan && !mem_cgroup_online(memcg))
>> > > > > 			scan = min(size, SWAP_CLUSTER_MAX);
>> > > > >
>> > > > > in get_scan_count doesn't work for that case?
>> > > >
>> > > > No, it doesn't. Let's look at the whole picture:
>> > > >
>> > > > 		size = lruvec_lru_size(lruvec, lru, sc->reclaim_idx);
>> > > > 		scan = size >> sc->priority;
>> > > > 		/*
>> > > > 		 * If the cgroup's already been deleted, make sure to
>> > > > 		 * scrape out the remaining cache.
>> > > > 		 */
>> > > > 		if (!scan && !mem_cgroup_online(memcg))
>> > > > 			scan = min(size, SWAP_CLUSTER_MAX);
>> > > >
>> > > > If size == 1, scan == 0 => scan = min(1, 32) == 1.
>> > > > And after proportional adjustment we'll have 0.
>> > >
>> > > My friday brain hurst when looking at this but if it doesn't work as
>> > > advertized then it should be fixed. I do not see any of your patches to
>> > > touch this logic so how come it would work after them applied?
>> >
>> > This part works as expected. But the following
>> > 	scan = div64_u64(scan * fraction[file], denominator);
>> > reliable turns 1 page to scan to 0 pages to scan.
>>
>> OK, 68600f623d69 ("mm: don't miss the last page because of round-off
>> error") sounds like a good and safe stable backport material.
>
>Thanks for this, now queued up.
>
>greg k-h

It seems that 172b06c32b949 ("mm: slowly shrink slabs with a relatively
small number of objects") and a76cf1a474d ("mm: don't reclaim inodes
with many attached pages") cause a regression reported against the 4.19
stable tree: https://bugzilla.kernel.org/show_bug.cgi?id=202441 .

Given the history and complexity of these (and other patches from that
series) it would be nice to understand if this is something that will be
fixed soon or should we look into reverting the series for now?

--
Thanks,
Sasha

