Return-Path: <SRS0=tSF5=RI=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74323C43381
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 13:01:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 368222082C
	for <linux-mm@archiver.kernel.org>; Tue,  5 Mar 2019 13:01:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 368222082C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=suse.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C39C48E0003; Tue,  5 Mar 2019 08:01:01 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BEA318E0001; Tue,  5 Mar 2019 08:01:01 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AD8D68E0003; Tue,  5 Mar 2019 08:01:01 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 45B658E0001
	for <linux-mm@kvack.org>; Tue,  5 Mar 2019 08:01:01 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id y26so4456634edb.4
        for <linux-mm@kvack.org>; Tue, 05 Mar 2019 05:01:01 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=dTh+h9x2S0zeOQjcFMBidhp0ceAClQPrs+kfjrIw4Zg=;
        b=gLET7cSS/G2Hbzs+vJSeFv6xiYLQsQa1lFwvzyZq/hS+PqpBbxLa3vPUZoGgf3a/cR
         caO7dG1EPxzScNR4gveuXLsbNwzdfnjhdef9v/qA8BC1D99uIBqoes5GXrkc37kRTvcQ
         e1e1DYVrhL9cM8xBKQDotfl4naRTVtNqIml/vp84o2v+xo9BLy0JeiZJBmFSoHruXpEA
         ofZMQGHIRFxYJUe6TuPkapEfJQvyE67+7KvEBeoXpQr/iuMVV0cNfdV4zJlw7QYQcFT3
         1mVo0l60i2UMIZ0JaCyt4rMW0yNdUzcIzHoDocqffIE3FQFhi470xxBY4a7A+3S8AjcR
         IIMw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Gm-Message-State: APjAAAVGOt/Oetl9PoBxqRCUo21I+yTuoiVXL9GmzP2hm2XBm6bUftWq
	5GguTvL2AQXTe6Zp6jKVRV/9oTAeR1CrBXvnATy2Sz9V57Ot7x2kI+UsVxaDXY+pXcsbODeI91f
	ZBW73+hBuzvyJLCdRdKN4Nyklq+Swx31snhtfL1ABmctAZK5/A/fFEnK0J2X17r7YZw==
X-Received: by 2002:a17:906:60d7:: with SMTP id f23mr153374ejk.177.1551790860750;
        Tue, 05 Mar 2019 05:01:00 -0800 (PST)
X-Google-Smtp-Source: APXvYqzJkSo51+dC6yfqmtD4VsuWvj1p0MGh1GOzt/UfIhVyMVWb5I0XAriEyn8dKi2BK5Ft3ouV
X-Received: by 2002:a17:906:60d7:: with SMTP id f23mr153306ejk.177.1551790859531;
        Tue, 05 Mar 2019 05:00:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551790859; cv=none;
        d=google.com; s=arc-20160816;
        b=OOjKFSNUNs7/vjktBS6dMQZ/NuHZC5EUeSSlWyD5B4Nq4nIbovuDNtoYnkHLlvjueS
         AZFjcwtSftf/snfoR+TsT/r580MmZeByAJ6s70i3KKzlhyqHzDwz14IHhghgyXjEf1xK
         NFfaKzOflGufpqPlxq0fTtWw1jjYN3bDLURN4mSM5CX3KX3xWUBPeb+a194jBm11zLf0
         L67nb6xC/5i76GQ+5LJpALyRGydc0kI5E1PWMntpRfMPmZroH7XyADJuWgMGqOMdCIUV
         DvepAF5gKOeRnXICQzMBc7eVnXPbQ8d6/pOakzyrIvFmw82OMqofvtx/0ciJgcmA8YQO
         rn0Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=dTh+h9x2S0zeOQjcFMBidhp0ceAClQPrs+kfjrIw4Zg=;
        b=y+M3tPi6+/P+0cfD3YR4wYUkV/1Vab9Sv1xtkbvSXbOSpxH9RSWFxCkWA3YLzY8jyW
         dK1G2hP6Ie7TdwId9XpwhDr1lI2K4bGJbzdG/jzNUEw4h6tN10QDUY2e52N4acWzPJH7
         l2zrLwApZqmLgc95IsAILji07VtLDGz63/JlaVlHql1gBuR7c2cAKmSOHwE7trb/DYm5
         fYx8CLPFQHnUSe06oOzAe5Fbqe9e8Jaso7haB1A+N6gc0EEKK6M0NejcBb/c1ph9dVjT
         ib64Nf9fTfqTNTTEZB0jL5SjvfRorhqjPx8C+vkv/KrXLImHhV18IWafyYd5SMQO9e8K
         8j4g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f20si3561648edd.56.2019.03.05.05.00.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Mar 2019 05:00:59 -0800 (PST)
Received-SPF: pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mhocko@suse.com designates 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@suse.com
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id F0DB7AED0;
	Tue,  5 Mar 2019 13:00:58 +0000 (UTC)
Date: Tue, 5 Mar 2019 14:00:58 +0100
From: Michal Hocko <mhocko@suse.com>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
	Vlastimil Babka <vbabka@suse.cz>,
	Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org,
	Hugh Dickins <hughd@google.com>,
	"Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>,
	Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 0/2] RFC: READ/WRITE_ONCE vma/mm cleanups
Message-ID: <20190305130058.GH28468@dhcp22.suse.cz>
References: <20190301035550.1124-1-aarcange@redhat.com>
 <20190301093729.wa4phctbvplt5pg3@kshutemo-mobl1>
 <3e8b2ff0-d188-5259-b488-e31355e1e8ad@suse.cz>
 <20190301165452.GP14294@redhat.com>
 <20190304101209.klwojazhtr4s4reu@kshutemo-mobl1>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190304101209.klwojazhtr4s4reu@kshutemo-mobl1>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon 04-03-19 13:12:10, Kirill A. Shutemov wrote:
> On Fri, Mar 01, 2019 at 11:54:52AM -0500, Andrea Arcangeli wrote:
> > Hello Kirill and Vlastimil,
> > 
> > On Fri, Mar 01, 2019 at 02:04:38PM +0100, Vlastimil Babka wrote:
> > > On 3/1/19 10:37 AM, Kirill A. Shutemov wrote:
> > > > On Thu, Feb 28, 2019 at 10:55:48PM -0500, Andrea Arcangeli wrote:
> > > >> Hello,
> > > >>
> > > >> This was a well known issue for more than a decade, but until a few
> > > >> months ago we relied on the compiler to stick to atomic accesses and
> > > >> updates while walking and updating pagetables.
> > > >>
> > > >> However now the 64bit native_set_pte finally uses WRITE_ONCE and
> > > >> gup_pmd_range uses READ_ONCE as well.
> > > >>
> > > >> This convert more racy VM places to avoid depending on the expected
> > > >> compiler behavior to achieve kernel runtime correctness.
> > > >>
> > > >> It mostly guarantees gcc to do atomic updates at 64bit granularity
> > > >> (practically not needed) and it also prevents gcc to emit code that
> > > >> risks getting confused if the memory unexpectedly changes under it
> > > >> (unlikely to ever be needed).
> > > >>
> > > >> The list of vm_start/end/pgoff to update isn't complete, I covered the
> > > >> most obvious places, but before wasting too much time at doing a full
> > > >> audit I thought it was safer to post it and get some comment. More
> > > >> updates can be posted incrementally anyway.
> > > > 
> > > > The intention is described well to my eyes.
> > > > 
> > > > Do I understand correctly, that it's attempt to get away with modifying
> > > > vma's fields under down_read(mmap_sem)?
> > 
> > The issue is that we already get away with it, but we do it without
> > READ/WRITE_ONCE. The patch should changes nothing, it should only
> > reduce the dependency on the compiler to do what we expect.
> 
> Yes, it is pre-existing problem. And yes, complier may screw this up.
> The patch may reduce dependency on the compiler, but it doesn't mean it
> reduces chance of race.
> 
> Consider your changes into __mm_populate() and populate_vma_page_range().
> You put READ_ONCE() in both functions. But populate_vma_page_range() gets
> called from __mm_populate(). Before your change compiler may optimize the
> code and load from the memory once for a field. With your changes complier
> will issue two loads.
> 
> It *increases* chances of the race, not reduces them.
> 
> The current locking scheme doesn't allow modifying VMA field without
> down_write(mmap_sem).
> 
> We do have hacks[1] that try to bypass the limitation, but AFAIK we never
> had a solid explanation why this should work. Sparkling READ_ONCE()
> doesn't help with this, but makes it appears legitimate.

I do agree with Kirill here. Sprinkling {READ,WRITE}_ONCE around just
doesn't solve anything. I am pretty sure that people will not think
about it and we will end up in a similar half covered situation in few
years again. I would rather remove all those hacks and use a saner
locking scheme instead.

> [1] I believe we also touch vm_flags without proper locking to set/clear
> VM_LOCKED.

-- 
Michal Hocko
SUSE Labs

