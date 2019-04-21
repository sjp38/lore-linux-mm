Return-Path: <SRS0=izd7=SX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CFA43C10F14
	for <linux-mm@archiver.kernel.org>; Sun, 21 Apr 2019 21:16:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 51E1320870
	for <linux-mm@archiver.kernel.org>; Sun, 21 Apr 2019 21:16:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 51E1320870
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8DA146B0003; Sun, 21 Apr 2019 17:16:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 863696B0006; Sun, 21 Apr 2019 17:16:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 72AE86B0007; Sun, 21 Apr 2019 17:16:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1E8E86B0003
	for <linux-mm@kvack.org>; Sun, 21 Apr 2019 17:16:08 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y4so4921174edo.8
        for <linux-mm@kvack.org>; Sun, 21 Apr 2019 14:16:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=Z4LorMPRPxWgJ6qu2lCv38u+QKsYqeyCamf3ZQLee70=;
        b=tjpBtKmDIh+28Sa4P+zajxIILyePnFTUJTeGEIDPZ5NaxdvMzEckVJjLjrVaotM4Ri
         3U5P5tVKxMeJTf6Bmrv6pS25QrXX3Ay/tchAe2qINGW/zMZK1BYpem1PgBHBb29jP2Nr
         jED1oosNRIZu+7cD32XNAPQoTgIKhIXsnlXhy5pm8V+XfwgrKEZZFShqox/HE8Z9nn1W
         pvLs/6LgHRVCNMWILjWzKbc95icYhwU8zxjAKZrwilLCoyzUJLCsJwlijrac/qBKZ0qV
         SGrvGMB3HDJafQFq9SudQz2JzJ42iqj1a2Y3Ihnex1wo3jjp7DFq5YeyStRnZEh5ekwt
         e1zw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.7 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAVmtpwUZ8108nRkZBmO0mm1OzTBoMgHSVTojgrkgS2C7rMRj4+c
	5oYuLNRjEgI/63zLBtWI2l7K41dkj/sJC3UI3qSGLQoxE58dKjlSu4GOb3gG5lsk9Hg76HwmaIX
	s7uDwnSH+YaUyskvad2yamTNHqMD72l2RtgZplTCVEG/qfbkAsQeReRgbIBwkWAt6fA==
X-Received: by 2002:a50:b797:: with SMTP id h23mr10212308ede.133.1555881367614;
        Sun, 21 Apr 2019 14:16:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzmsW5HGJsDKrNF3NwyByVOOtE5bCltc6ket2PMxehEL5PaTzRKyMDV6h4/XcJXGrzfFSPd
X-Received: by 2002:a50:b797:: with SMTP id h23mr10212278ede.133.1555881366757;
        Sun, 21 Apr 2019 14:16:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555881366; cv=none;
        d=google.com; s=arc-20160816;
        b=YYM4C5agSKWqanU0vi2FUsoE5/lMvXbN2B9p5Sh+lBXOKLFuwWn1N8RWLKiMDB6inX
         klGD93x7IUHmx2QLvD2dszZfFMK1gGn8hzvx/JjfHQEJxcId2xRQgBVm/pusf15XiiKw
         2E+peH492Jc0ACuqlHhlP/yBmfuNs2BXgXnt8Ly8HxsXwpYZc59s4olojueu9r9m4/cw
         MX9u0uBTjWCmbpddYB/t9vTtyeNxInvh+ZWBJNnn63TgIqwAilJnZTl1skEpBVdaympa
         5lYdiQQhQmRFDgGc5YmWH3gHpz2DwRtdBTXxzh64FmhcbD3XUAqvkfYYwX6IXjkwDZN5
         +o5Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=Z4LorMPRPxWgJ6qu2lCv38u+QKsYqeyCamf3ZQLee70=;
        b=Iqdvexr6I3sPJwwg/+liqsdY8Dfx4Gv/d9RSluCZvMBwqQELuhceQPm5HlZQFcrGAB
         +OBtatHNcReK7Y/I4ql4V0BfAwGIv+HfUBRskiM6uqN5skhdTGkvEdwncnijp6VWHN+/
         OOorFVVoWg2tnrcap+67Haw0gQx1jc3CS9+eGKe57qoXF2LtIIFbLUJyoWHq5KMHGIlH
         ANv7OTZxGE37rUoVV4R5Lr5/P9F495QK0vMLMfIglgRqcqqqZoPDf6nkXTFs+ALAfusy
         W8uvUdOo9k0ZvHe9Q5ypngFG6o1nQPTaPw/QHFY2+9wFvJAN4hpRxndnymsYJyjTmOz/
         PN7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.7 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp01.blacknight.com (outbound-smtp01.blacknight.com. [81.17.249.7])
        by mx.google.com with ESMTPS id d2si1689307edb.202.2019.04.21.14.16.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Apr 2019 14:16:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.7 as permitted sender) client-ip=81.17.249.7;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 81.17.249.7 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp01.blacknight.com (Postfix) with ESMTPS id 48D7398B1E
	for <linux-mm@kvack.org>; Sun, 21 Apr 2019 21:16:06 +0000 (UTC)
Received: (qmail 12317 invoked from network); 21 Apr 2019 21:16:06 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 21 Apr 2019 21:16:06 -0000
Date: Sun, 21 Apr 2019 22:16:04 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Matthew Wilcox <willy@infradead.org>
Cc: Mike Rapoport <rppt@linux.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mikulas Patocka <mpatocka@redhat.com>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	linux-parisc@vger.kernel.org, linux-mm@kvack.org,
	Vlastimil Babka <vbabka@suse.cz>,
	LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org
Subject: Re: DISCONTIGMEM is deprecated
Message-ID: <20190421211604.GN18914@techsingularity.net>
References: <20190419094335.GJ18914@techsingularity.net>
 <20190419140521.GI7751@bombadil.infradead.org>
 <20190421063859.GA19926@rapoport-lnx>
 <20190421132606.GJ7751@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190421132606.GJ7751@bombadil.infradead.org>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, Apr 21, 2019 at 06:26:07AM -0700, Matthew Wilcox wrote:
> On Sun, Apr 21, 2019 at 09:38:59AM +0300, Mike Rapoport wrote:
> > On Fri, Apr 19, 2019 at 07:05:21AM -0700, Matthew Wilcox wrote:
> > > On Fri, Apr 19, 2019 at 10:43:35AM +0100, Mel Gorman wrote:
> > > > DISCONTIG is essentially deprecated and even parisc plans to move to
> > > > SPARSEMEM so there is no need to be fancy, this patch simply disables
> > > > watermark boosting by default on DISCONTIGMEM.
> > > 
> > > I don't think parisc is the only arch which uses DISCONTIGMEM for !NUMA
> > > scenarios.  Grepping the arch/ directories shows:
> > > 
> > > alpha (does support NUMA, but also non-NUMA DISCONTIGMEM)
> > > arc (for supporting more than 1GB of memory)
> > > ia64 (looks complicated ...)
> > > m68k (for multiple chunks of memory)
> > > mips (does support NUMA but also non-NUMA)
> > > parisc (both NUMA and non-NUMA)
> > 
> > i386 NUMA as well
> 
> I clearly over-trimmed.  The original assumption that Mel had was that
> DISCONTIGMEM => NUMA, and that's not true on the above six architectures.
> It is true on i386 ;-)

32-bit NUMA systems should be non-existent in practice. The last NUMA
system I'm aware of that was both NUMA and 32-bit only died somewhere
between 2004 and 2007. If someone is running a 64-bit capable system in
32-bit mode with NUMA, they really are just punishing themselves for fun.

-- 
Mel Gorman
SUSE Labs

