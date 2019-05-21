Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: *
X-Spam-Status: No, score=1.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	FSL_HELO_FAKE,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,USER_AGENT_MUTT
	autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A14F9C04E87
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:39:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4366021743
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 04:39:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="QO5rQwSX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4366021743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AEE3F6B0003; Tue, 21 May 2019 00:39:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A9EA16B0005; Tue, 21 May 2019 00:39:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 98DD16B0006; Tue, 21 May 2019 00:39:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 625D46B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 00:39:58 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id e20so11473658pfn.8
        for <linux-mm@kvack.org>; Mon, 20 May 2019 21:39:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:sender:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=QQkwhZ+FrBt0iCq5K6YROwDY4dt6/xx+/myXpnuTWx4=;
        b=sUiitE2y2Idp9JARAx9tJHxWjFC4vvGtajLuIrfAoyNAvjNetSAH6JjVSE3wzrG/IO
         tF1XX1AUZmjRDXlWD3ViPcz5KKfd7QXX/ZMfyuVoIhbueretJARzox6Pt1xXoC9nPj5b
         2WsuIxD61ioKyioVNozqgNFKvoaLpvdvgqBZeW+uZaYd70/kSw3rNwWwvjgd3v3oTwXB
         dUK0yo84m09zDvEUZAS2HLwtVp+aXpDwYBRnr/creoWD0j8ajClcUs9nHvyVsD9EvKxF
         2Bbtij+ZzCb2uK+WYcZRPQSD9NFJ8X6KscKzYlD8DAiI05knWKSExB9B0a3nCmlo/M03
         ZtZQ==
X-Gm-Message-State: APjAAAXV/bDafa7qLpEGRCYSombyTOiV2KzosXg68opZUtEiV71r+Vc5
	U9zjrF2m6P+AHdL+xs6OIoH/thOBnxZC1ipr+EsGLMBiOxQsXpla02iKAYaRgKUXavYob6EvNPg
	VfJW6HucvVGR3RsEWEQzhqVzVelAjrVD0U8jI5j8hlBBQ80vMLLPVUzS8I4YkY2w=
X-Received: by 2002:aa7:8083:: with SMTP id v3mr20629568pff.135.1558413597973;
        Mon, 20 May 2019 21:39:57 -0700 (PDT)
X-Received: by 2002:aa7:8083:: with SMTP id v3mr20629509pff.135.1558413597139;
        Mon, 20 May 2019 21:39:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558413597; cv=none;
        d=google.com; s=arc-20160816;
        b=nobi8yA4NMXDPeIwghCZjvbV8w3K/gRAV81WowJ+f3EwG4Mln2dWKGPklSuoMI2R0K
         acLhJwsbatGoEKYaoHHLCnPjAooY0ZmrYmo6rtDQoAgQ0xaFj0daUPHW+nJHTSdYrnIv
         zMjG7eM0OiiE1/M7iI4KvMObPNdmer7UK4YCRDE6BLHKzsQyMioYqRRZ49I9HaQF1NFE
         xDyQNFOVDCFwVDEtKAj/TQNJjmqtpkR7yRz7bS799SNwKL+ALhinQ/LjX1dbClrRa+0G
         xfsCgxrdV9U//1wI9qzMRW9GhMO67z4r3GbkGfdTYtxfuNWc2H1uW94stNiDbVHDnlP7
         YDHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date:sender:dkim-signature;
        bh=QQkwhZ+FrBt0iCq5K6YROwDY4dt6/xx+/myXpnuTWx4=;
        b=AOFxo2jGVRAWF0ieeS5b/h8lQGAaNlLI9m1IiUBMTEV4gIULOzlySXFAhSwK+XIGFO
         rtYhFQcsX+scaMgWU+gQcUX/aq849h1Q6zhbJ00nIpOowHEaz6sltV1/zDC4cG3o6Egn
         tBXavGV0VhaZb6+Ca15ALpGip5+Vdu06IIgOOXt1Gs+C/GJ6ve8xeLN6sRzxfQTt89SF
         ARz/yrIWSKvR5SbemsIe3NDk3gMIsFZLurIbs3NbRSWsjrKq3Z5CWkA34uPXkZ18B12D
         1zNqGruFeSgaVxCG7L6MzIiChesmvqkVDRcMd79ikbEfwgwnDDJuAWPKkzLx9+VOoMl6
         57/g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QO5rQwSX;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r144sor11736683pgr.57.2019.05.20.21.39.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 May 2019 21:39:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=QO5rQwSX;
       spf=pass (google.com: domain of minchan.kim@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=minchan.kim@gmail.com;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=sender:date:from:to:cc:subject:message-id:references:mime-version
         :content-disposition:content-transfer-encoding:in-reply-to
         :user-agent;
        bh=QQkwhZ+FrBt0iCq5K6YROwDY4dt6/xx+/myXpnuTWx4=;
        b=QO5rQwSX4v25HATvAZksTfI6EjXr31E65ISg3wa7Rgi+45wh+Nc67s/QBio/bGiCxj
         XpXtutx7gPssH+Xd9sCjEzvAXWl+YYTuoMcSfqUB6YdCsqDiXmbCW/gEzauJ473iqGp+
         +kVbmM7thyPsWxY6WFV9RGiW3WLCVx/uv3vQHpy3NPuH/7R1CrZmIljMx9pvsxRuXkbc
         7SoMfs2fQkMEeDeNLJ3eNAzSQy4VDAMh4OrN9FQMY+8f8ARo/KGLQ7dX4UID1aDS3epb
         DbYbiaD39kGowIZ66+bRqNKIIsPg3h3p+/6PQAr9RDHCrsN+XINT4BdkIBXTqVSEWNnl
         OcGg==
X-Google-Smtp-Source: APXvYqyhPph8JUAv8OXabcKgL76/7+E4blBN6RjxyY6+rf84o1rFnhmanK/CfaV5snMHaIbjmb0bnA==
X-Received: by 2002:a63:c64c:: with SMTP id x12mr78971864pgg.379.1558413596600;
        Mon, 20 May 2019 21:39:56 -0700 (PDT)
Received: from google.com ([2401:fa00:d:0:98f1:8b3d:1f37:3e8])
        by smtp.gmail.com with ESMTPSA id w12sm29519966pfj.41.2019.05.20.21.39.52
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Mon, 20 May 2019 21:39:55 -0700 (PDT)
Date: Tue, 21 May 2019 13:39:50 +0900
From: Minchan Kim <minchan@kernel.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>,
	Michal Hocko <mhocko@suse.com>, Tim Murray <timmurray@google.com>,
	Joel Fernandes <joel@joelfernandes.org>,
	Suren Baghdasaryan <surenb@google.com>,
	Daniel Colascione <dancol@google.com>,
	Shakeel Butt <shakeelb@google.com>, Sonny Rao <sonnyrao@google.com>,
	Brian Geffon <bgeffon@google.com>
Subject: Re: [RFC 0/7] introduce memory hinting API for external process
Message-ID: <20190521043950.GJ10039@google.com>
References: <20190520035254.57579-1-minchan@kernel.org>
 <20190520164605.GA11665@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190520164605.GA11665@cmpxchg.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, May 20, 2019 at 12:46:05PM -0400, Johannes Weiner wrote:
> On Mon, May 20, 2019 at 12:52:47PM +0900, Minchan Kim wrote:
> > - Approach
> > 
> > The approach we chose was to use a new interface to allow userspace to
> > proactively reclaim entire processes by leveraging platform information.
> > This allowed us to bypass the inaccuracy of the kernel’s LRUs for pages
> > that are known to be cold from userspace and to avoid races with lmkd
> > by reclaiming apps as soon as they entered the cached state. Additionally,
> > it could provide many chances for platform to use much information to
> > optimize memory efficiency.
> > 
> > IMHO we should spell it out that this patchset complements MADV_WONTNEED
> > and MADV_FREE by adding non-destructive ways to gain some free memory
> > space. MADV_COLD is similar to MADV_WONTNEED in a way that it hints the
> > kernel that memory region is not currently needed and should be reclaimed
> > immediately; MADV_COOL is similar to MADV_FREE in a way that it hints the
> > kernel that memory region is not currently needed and should be reclaimed
> > when memory pressure rises.
> 
> I agree with this approach and the semantics. But these names are very
> vague and extremely easy to confuse since they're so similar.
> 
> MADV_COLD could be a good name, but for deactivating pages, not
> reclaiming them - marking memory "cold" on the LRU for later reclaim.
> 
> For the immediate reclaim one, I think there is a better option too:
> In virtual memory speak, putting a page into secondary storage (or
> ensuring it's already there), and then freeing its in-memory copy, is
> called "paging out". And that's what this flag is supposed to do. So
> how about MADV_PAGEOUT?
> 
> With that, we'd have:
> 
> MADV_FREE: Mark data invalid, free memory when needed
> MADV_DONTNEED: Mark data invalid, free memory immediately
> 
> MADV_COLD: Data is not used for a while, free memory when needed
> MADV_PAGEOUT: Data is not used for a while, free memory immediately
> 
> What do you think?

There are several suggestions until now. Thanks, Folks!

For deactivating:

- MADV_COOL
- MADV_RECLAIM_LAZY
- MADV_DEACTIVATE
- MADV_COLD
- MADV_FREE_PRESERVE


For reclaiming:

- MADV_COLD
- MADV_RECLAIM_NOW
- MADV_RECLAIMING
- MADV_PAGEOUT
- MADV_DONTNEED_PRESERVE

It seems everybody doesn't like MADV_COLD so want to go with other.
For consisteny of view with other existing hints of madvise, -preserve
postfix suits well. However, originally, I don't like the naming FREE
vs DONTNEED from the beginning. They were easily confused.
I prefer PAGEOUT to RECLAIM since it's more likely to be nuance to
represent reclaim with memory pressure and is supposed to paged-in
if someone need it later. So, it imply PRESERVE.
If there is not strong against it, I want to go with MADV_COLD and
MADV_PAGEOUT.

Other opinion?

