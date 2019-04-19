Return-Path: <SRS0=hU9b=SV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A42FCC282DA
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 14:28:40 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 67442222C4
	for <linux-mm@archiver.kernel.org>; Fri, 19 Apr 2019 14:28:40 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 67442222C4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C155A6B0003; Fri, 19 Apr 2019 10:28:39 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BC1166B0006; Fri, 19 Apr 2019 10:28:39 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AB12B6B0007; Fri, 19 Apr 2019 10:28:39 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5D50D6B0003
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 10:28:39 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id o8so2929320edh.12
        for <linux-mm@kvack.org>; Fri, 19 Apr 2019 07:28:39 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=LUIQ54xgTpObEJh5us6KXdVv/bDckSRhn4O+VMkjd/k=;
        b=UR1pDgp3mBO3LXcgvH7Ncmv2XXx1fCm7lisGVx5kNKWH+JwFeIvAc7yPSzG2x2bGDn
         F5fsyK7Lv+FNNIIITgMLDaEoZoiH/Vpj7fALAi3BtAxRZDDqjuyGuDnbZsYNrg3Hr5T7
         77kJspS172UW/WY+Mv/RvNdKq2VWeUEw1LNtt5x3NEsSn58iYw5G4jYFMAnX4ujb3GBa
         FoSP/iXdm2HG+d7Bam0T0p7yOyYZoCTnrGgpWUg8E1v6eIPhEET7XP/FzO9/mVbM1Xxj
         ilVh+zHFquUQ99KZspYd9J7mS8X02w6EOnImztcQ7GmrFmysyXSzorool0wXw3FkeooC
         NMrw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.231 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAU7EATrgSRDF62O2z82IIVi0VBGII0O4PgkUyXkA4uoI09r3pdE
	8aDgY2+UHJY0do/WVsFR1T1sSIFzexb+GBgtHDZ47zdwMrVYZ7YBbioETe/RqzJc/Lq0MJ0/XX0
	wHUz4clR5te3CWR+wMpQ1zhwi0nfHw8cp9JnpWgAN1hdDKMm6L/GaW3aSxst3+SgtgQ==
X-Received: by 2002:a17:906:5a59:: with SMTP id l25mr2172195ejs.122.1555684118925;
        Fri, 19 Apr 2019 07:28:38 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyzVTBLyTtbR0p+f3lhs8aQAKHuc6A4Q3T8eJrqt+CoLZAxAvjyYUZB0FudbA50AXFW35n4
X-Received: by 2002:a17:906:5a59:: with SMTP id l25mr2172163ejs.122.1555684118056;
        Fri, 19 Apr 2019 07:28:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555684118; cv=none;
        d=google.com; s=arc-20160816;
        b=vfKnuPZ9JlYuVbgnPfTSBg4ntMZRRuTEgN+rTeC6/J8Ji4GcFwmovdCT+FYVk1uRm6
         /az7G6Xng8fHWVZia6Md/yz6C9d5I86KV47bHid/E6ZGgZcG/HXjoO0FR974tbFFtYDl
         CA8rt+72yL+VI1OocQ9CAwLgBWDTTg4zyuK2xxYzUXXdmmjRY+B4NJ+8ZyiXjjPo0VBI
         JvoxxmekljfR+DDQKbwKKgvBfNfdBrNhDGHEDsTUDOhp1bC55nMxzGp/Yj07mu5WCIcM
         hzWE4nb7BsNeVYJd84RtVT8bubLToDguWU8hO6UV645arZ1WtXZAqUyCMvbbypAVGVqO
         u5vg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=LUIQ54xgTpObEJh5us6KXdVv/bDckSRhn4O+VMkjd/k=;
        b=TQ9E/caBupoQVYwxyiY+TuOOSVjWA8W/eAYCqdaurzP6HyhVQaADJysnqQA5nA/kZ7
         zsQx6uUy0p9bxqHouVBcrhxcCDB1oAcyTpV/4ZavRZ5uz3EpmbgaAyuSdSHKvhGlGLJZ
         W/Wo0uA+q+S1Byd5GJ+tw5Ix6pVeSSz4TJRVR/GVvikS0of+oFRrjr+5zpPGy6KjyObg
         yHqdq7RyAAECxbx7+UvLOdAF4jhMYnZNtBvBuYmG29Kp6pjWJv0aIZ5CPYBRUUnZLEz0
         qokelmPRConfL+bTYPZ4RTM5L9b7M0L9X7KO262ddh0W0gXCylXTayZCpRXW9rBMfXkd
         ryyA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.231 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp14.blacknight.com (outbound-smtp14.blacknight.com. [46.22.139.231])
        by mx.google.com with ESMTPS id k33si2517865edb.13.2019.04.19.07.28.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Apr 2019 07:28:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.231 as permitted sender) client-ip=46.22.139.231;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.231 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (unknown [81.17.254.17])
	by outbound-smtp14.blacknight.com (Postfix) with ESMTPS id 797241C2B95
	for <linux-mm@kvack.org>; Fri, 19 Apr 2019 15:28:37 +0100 (IST)
Received: (qmail 11311 invoked from network); 19 Apr 2019 14:28:37 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 19 Apr 2019 14:28:37 -0000
Date: Fri, 19 Apr 2019 15:28:35 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Mikulas Patocka <mpatocka@redhat.com>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	linux-parisc@vger.kernel.org, linux-mm@kvack.org,
	Vlastimil Babka <vbabka@suse.cz>,
	LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org
Subject: Re: DISCONTIGMEM is deprecated
Message-ID: <20190419142835.GM18914@techsingularity.net>
References: <20190419094335.GJ18914@techsingularity.net>
 <20190419140521.GI7751@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190419140521.GI7751@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Apr 19, 2019 at 07:05:21AM -0700, Matthew Wilcox wrote:
> On Fri, Apr 19, 2019 at 10:43:35AM +0100, Mel Gorman wrote:
> > DISCONTIG is essentially deprecated and even parisc plans to move to
> > SPARSEMEM so there is no need to be fancy, this patch simply disables
> > watermark boosting by default on DISCONTIGMEM.
> 
> I don't think parisc is the only arch which uses DISCONTIGMEM for !NUMA
> scenarios.  Grepping the arch/ directories shows:
> 
> alpha (does support NUMA, but also non-NUMA DISCONTIGMEM)
> arc (for supporting more than 1GB of memory)
> ia64 (looks complicated ...)
> m68k (for multiple chunks of memory)
> mips (does support NUMA but also non-NUMA)
> parisc (both NUMA and non-NUMA)
> 
> I'm not sure that these architecture maintainers even know that DISCONTIGMEM
> is deprecated.  Adding linux-arch to the cc.

Poor wording then -- yes, DISCONTIGMEM is still used but look where it's
used. I find it impossible to believe that any new arch would support
DISCONTIGMEM or that DISCONTIGMEM would be selected when SPARSEMEM is
available.`It's even more insane when you consider that SPARSEMEM can be
extended to support VMEMMAP so that it has similar overhead to FLATMEM
when mapping pfns to struct pages and vice-versa.

-- 
Mel Gorman
SUSE Labs

