Return-Path: <SRS0=d6aY=VB=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_SANE_1
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 91BC8C46497
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 20:54:56 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 43F69218A0
	for <linux-mm@archiver.kernel.org>; Thu,  4 Jul 2019 20:54:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 43F69218A0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CBB676B0003; Thu,  4 Jul 2019 16:54:55 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C6D828E0003; Thu,  4 Jul 2019 16:54:55 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B5C3C8E0001; Thu,  4 Jul 2019 16:54:55 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 684396B0003
	for <linux-mm@kvack.org>; Thu,  4 Jul 2019 16:54:55 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id a5so4399391edx.12
        for <linux-mm@kvack.org>; Thu, 04 Jul 2019 13:54:55 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:message-id:date:user-agent:mime-version:in-reply-to
         :content-language:content-transfer-encoding;
        bh=7SxXI+b2bsjD05kVF97jFxrTdXlxjR4WuIghnRRDqd4=;
        b=G6slBYm7yX0AGvWrBmqgi9NXQxq6aahANhM5/2qXHe8VaHIkYkg03VmiPhbKGlCr27
         RHO5W11BronMvGKi7TkFZjbS6XTxSjE2AWuKSc3d9J7w2sjGRiLlWJN7s/OmYaAHG961
         1/Dbp2gIvulIe/aKjRgSDgcNW4e8MrRW5a7yGSz0L9hH2sdBPrnm8ysaZU9oSvU1IVU1
         RfbdNv+AEKp/8YmlmhSFmJaTMYXKLwrs2e7oFckzy1Sfu1oa3HWbps1LgDrcweC2MxGd
         i8dPqXOC+rXGLmpatx+0NXFP7kbNJACOYZoiZe4sxER/2khW9Pgq16Io3G5461c9wNO3
         aoQQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAWlV6s1ijc55LinJ6NJ7p+RHAyvooi864LZhn6CBN6oPEYytriC
	2op/e8gkBM7JrUKCdf9o82Zu3qRhBHTmB8uObr3p//6pLTlfIH/NhK1fITyvpS89JRf3eico0Of
	0RbLk39BIF1vDpNtRWyzEHUwx8kMljztBbm9GCn/TLdHTX8PW+Un9qv0Hiq4I8dZCkA==
X-Received: by 2002:a17:906:28c4:: with SMTP id p4mr216256ejd.181.1562273694891;
        Thu, 04 Jul 2019 13:54:54 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwp8EFSGUhmW9dSEAEJGntTJcfFepjkcVBOjKc9QBett7ME5OJEyTmZgtoK+TamWsTaWqQB
X-Received: by 2002:a17:906:28c4:: with SMTP id p4mr216206ejd.181.1562273693960;
        Thu, 04 Jul 2019 13:54:53 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1562273693; cv=none;
        d=google.com; s=arc-20160816;
        b=akvrlmL040g8mNz8dis04DTZDpRdHnUVWy6isWmSgRKYiVyqNN0uc2H+8IkpxR2Fs6
         X130vs5UZ/x1zMm6hym80xsuicA27IBhZqtsCQW8SB0bKOS6J1agsVUBJjfWoMo3IDnp
         g6vPJLzl+IcyztIk7U1S9I4gxjmeycn8HEMBBsYmBMr9Fcz3818L6tpfKZcLshzRCaSW
         rimK6qMUJWOLT3cV/go9AMTT3dikI13mMx+zlrpSRbAbzj5lJcSp5vvMoaMxPUyCDfM9
         PiWQ+BqWtBEPxeFXe3awB61U6QvOIwTr6PoA5BUHOxJJFf/PyLQXABkmOA8CezxN+Fbj
         6iRg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:content-language:in-reply-to:mime-version
         :user-agent:date:message-id:from:references:cc:to:subject;
        bh=7SxXI+b2bsjD05kVF97jFxrTdXlxjR4WuIghnRRDqd4=;
        b=hV5gsxiLA9+Lz+m5dFyMWbyJ6NHUuCxIfvCNHPXqyVdI75M5HZsmceJRzqVuCOFCB6
         GieAabJzJj2lsTtEHVYVLXKaJa9MJHehrLWb+ug2HzTSgAgCiTaIe9I/3Wf1Toc8n4ug
         EDDW15kQg4WL3VvwgyccM9aqwUdB5S3IiOitEEs8Jy6G7879SEoui7QRX6wfTqEU2HeN
         +JqE/LRs4KYyPwDNGGoVyoBSlKu1jboJZ4lZbG9iOHiUYFYf0DyCJa8693W0NY4/bNLK
         8gdpi83Y9E9Rf4XnPaD/EiZ0VVXI8uoC0WBspU7gPKXgigXEzNJOK2p/G3gPuEm9moc5
         K4Sg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id o26si5872969edc.423.2019.07.04.13.54.53
        for <linux-mm@kvack.org>;
        Thu, 04 Jul 2019 13:54:53 -0700 (PDT)
Received-SPF: pass (google.com: domain of robin.murphy@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id A517928;
	Thu,  4 Jul 2019 13:54:52 -0700 (PDT)
Received: from [192.168.1.123] (unknown [172.31.20.19])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B922D3F738;
	Thu,  4 Jul 2019 13:54:50 -0700 (PDT)
Subject: Re: [PATCH v3 0/4] Devmap cleanups + arm64 support
To: Jason Gunthorpe <jgg@mellanox.com>,
 Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@infradead.org>, Mark Rutland
 <mark.rutland@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>,
 "will.deacon@arm.com" <will.deacon@arm.com>,
 "catalin.marinas@arm.com" <catalin.marinas@arm.com>,
 "anshuman.khandual@arm.com" <anshuman.khandual@arm.com>,
 "linux-arm-kernel@lists.infradead.org"
 <linux-arm-kernel@lists.infradead.org>,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
 Michal Hocko <mhocko@suse.com>, Dan Williams <dan.j.williams@intel.com>
References: <cover.1558547956.git.robin.murphy@arm.com>
 <20190626073533.GA24199@infradead.org>
 <20190626123139.GB20635@lakrids.cambridge.arm.com>
 <20190626153829.GA22138@infradead.org> <20190626154532.GA3088@mellanox.com>
 <20190626203551.4612e12be27be3458801703b@linux-foundation.org>
 <20190704115324.c9780d01ef6938ab41403bf9@linux-foundation.org>
 <20190704195934.GA23542@mellanox.com>
From: Robin Murphy <robin.murphy@arm.com>
Message-ID: <de2286d9-6f5c-a79c-dcee-de4225aca58a@arm.com>
Date: Thu, 4 Jul 2019 21:54:36 +0100
User-Agent: Mozilla/5.0 (Windows NT 10.0; rv:60.0) Gecko/20100101
 Thunderbird/60.7.0
MIME-Version: 1.0
In-Reply-To: <20190704195934.GA23542@mellanox.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-GB
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On 2019-07-04 8:59 pm, Jason Gunthorpe wrote:
> On Thu, Jul 04, 2019 at 11:53:24AM -0700, Andrew Morton wrote:
>> On Wed, 26 Jun 2019 20:35:51 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
>>
>>>> Let me know and I can help orchestate this.
>>>
>>> Well.  Whatever works.  In this situation I'd stage the patches after
>>> linux-next and would merge them up after the prereq patches have been
>>> merged into mainline.  Easy.
>>
>> All right, what the hell just happened?

Aw crap, and I had this series chalked up as done...

> Christoph's patch series for the devmap & hmm rework finally made it
> into linux-next, sorry, it took quite a few iterations on the list to
> get all the reviews and tests, and figure out how to resolve some
> other conflicting things. So it just made it this week.
> 
> Recall, this is the patch series I asked you about routing a few weeks
> ago, as it really exceeded the small area that hmm.git was supposed to
> cover. I think we are both caught off guard how big the conflict is!
> 
>> A bunch of new material has just been introduced into linux-next.
>> I've partially unpicked the resulting mess, haven't dared trying to
>> compile it yet.  To get this far I'll need to drop two patch series
>> and one individual patch:
>    
>> mm-clean-up-is_device__page-definitions.patch
>> mm-introduce-arch_has_pte_devmap.patch
>> arm64-mm-implement-pte_devmap-support.patch
>> arm64-mm-implement-pte_devmap-support-fix.patch
> 
> This one we discussed, and I thought we agreed would go to your 'stage
> after linux-next' flow (see above). I think the conflict was minor
> here.

I can rebase and resend tomorrow if there's an agreement on what exactly 
to base it on - I'd really like to get this ticked off for 5.3 if at all 
possible.

Thanks,
Robin.

>> mm-sparsemem-introduce-struct-mem_section_usage.patch
>> mm-sparsemem-introduce-a-section_is_early-flag.patch
>> mm-sparsemem-add-helpers-track-active-portions-of-a-section-at-boot.patch
>> mm-hotplug-prepare-shrink_zone-pgdat_span-for-sub-section-removal.patch
>> mm-sparsemem-convert-kmalloc_section_memmap-to-populate_section_memmap.patch
>> mm-hotplug-kill-is_dev_zone-usage-in-__remove_pages.patch
>> mm-kill-is_dev_zone-helper.patch
>> mm-sparsemem-prepare-for-sub-section-ranges.patch
>> mm-sparsemem-support-sub-section-hotplug.patch
>> mm-document-zone_device-memory-model-implications.patch
>> mm-document-zone_device-memory-model-implications-fix.patch
>> mm-devm_memremap_pages-enable-sub-section-remap.patch
>> libnvdimm-pfn-fix-fsdax-mode-namespace-info-block-zero-fields.patch
>> libnvdimm-pfn-stop-padding-pmem-namespaces-to-section-alignment.patch
> 
> Dan pointed to this while reviewing CH's series and said the conflicts
> would be manageable, but they are certainly larger than I expected!
> 
> This series is the one that seems to be the really big trouble. I
> already checked all the other stuff that Stephen resolved, and it
> looks OK and managable. Just this one conflict with kernel/memremap.c
> is beyond me.
> 
> What approach do you want to take to go forward? Here are some thoughts:
> 
> CH has said he is away for the long weekend, so the path that involves
> the fewest people is if Dan respins the above on linux-next and it
> goes later with the arm patches above, assuming defering it for now
> has no other adverse effects on -mm.
> 
> Pushing CH's series to -mm would need a respin on top of Dan's series
> above and would need to carry along the whole hmm.git (about 44
> patches). Signs are that this could be managed with the code currently
> in the GPU trees.
> 
> If we give up on CH's series the hmm.git will not have conflicts,
> however we just kick the can to the next merge window where we will be
> back to having to co-ordinate amd/nouveau/rdma git trees and -mm's
> patch workflow - and I think we will be worse off as we will have
> totally given up on a git based work flow for this. :(
> 
>> mm-sparsemem-cleanup-section-number-data-types.patch
>> mm-sparsemem-cleanup-section-number-data-types-fix.patch
> 
> Stephen used a minor conflict resolution for this one, I checked it
> carefully and it looked OK.
> 
>> I thought you were just going to move material out of -mm and into
>> hmm.git.
> 
> Dan brought up a patch from Ira conflicting with CH's work and we did
> handle that by moving a single patch, as well I moved several hmm
> specific patches early in the cycle.
> 
>> Didn't begin to suspect that new and quite disruptive material would
>> be introduced late in -rc7!!
> 
> Unfortunately a non-rebasing tree like hmm.git should only get patches
> into linux-next once they are fully reviewed and done on the list. I
> did not attempt to run separately patches 'under review' into
> linux-next as you do.
> 
> Actually I didn't even know this would benefit your workflow, rebasing
> patches on top of linux-next is not part of the git based workflow I'm
> using :(
> 
> AFAIK Dan and CH were both tracking conflicts with linux-next, so I'd
> like to hear from Dan what he thinks about his series, maybe the
> rebase is simple & safe for him? Dan and CH were working pretty
> closely on CH's series.
> 
> Jason
> 

