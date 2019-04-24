Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 864A2C282E1
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 12:22:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4E93E21773
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 12:22:00 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4E93E21773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=techsingularity.net
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D05ED6B0005; Wed, 24 Apr 2019 08:21:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C8D0A6B0006; Wed, 24 Apr 2019 08:21:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B30C46B0007; Wed, 24 Apr 2019 08:21:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 635716B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 08:21:59 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x21so7500140edx.23
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 05:21:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :in-reply-to:user-agent;
        bh=6WhskxsObSNh1saZcmrK2YNjE5IY2TOs+LSquGXjHIU=;
        b=GeeKKsFLkc9ASt/PGGpXJ00RzkIoildB2ddUQsh3shh0PXhpGinkPHR107XrehUOl2
         2OBqqevRpKWxH6cAFSg9jmRCd02KDETdrxZ3h6xkEOXPiAga+f8iYFH7XFMiNCvuZrCA
         fePwsYJ4BGDCb10d1DsQqFVyG9xo2mwo9k+cDK9pwdXFCbvLxGtgSdYoA6Tbm/VrG+oK
         PcYJoh7Wd7cbUK39g5AK6j0LerpFVKAYxJwStfF8xO5UEjn4NPqLwpthTUkBthj5+GVE
         SUPe6lppQxcnfX9lcREEmBKMY61LRtTRDstP1/pufCvNkcfwhG47orvHvF25eZAUF42J
         qPWw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
X-Gm-Message-State: APjAAAVUNiiGG5Mg88wOvwef8otzTWJy124DEAV2AfyRqGZg/EsmxTYj
	XfaUkpt06FWwO7iSvl+A8QXPBq9ID69s9Oh/x5h7yhekQ/aTA50pPB/gLVAsnoii4aSDDhrpKUs
	kJ/tjUyCP9dyNTcIi8asmCP4ZodbY9Kg7ngF901kCOV2+cMcEebwt9piFkKkHSeUUhA==
X-Received: by 2002:a17:906:3d31:: with SMTP id l17mr16205376ejf.67.1556108518904;
        Wed, 24 Apr 2019 05:21:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxOZqBwWmweOyU70ftDQ7i1HjkFUHi2bVvTkBrIEfntfN+zGlc1ml1f99N1tiiiOOLfVzbg
X-Received: by 2002:a17:906:3d31:: with SMTP id l17mr16205341ejf.67.1556108518041;
        Wed, 24 Apr 2019 05:21:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556108518; cv=none;
        d=google.com; s=arc-20160816;
        b=I0GDnhAIsOzw6VD9hxeRCCzHpQzVi7wZQlvKgQ+1H5GwXKUy+XraqQ3YqzWIVUVTKO
         pYx1fWPrhAGghBOQ/wfN4foLbNNbzBhfPmKKguI7RUicAZVSirMimkO138vwV0xvbrNe
         Xe+Oi9aEQURNYuAz8cDVm5gUaE3qsPkb4zfuX67hjbxYleXTu6HTjSNEQ2xVlXkorLHs
         eA7mLYAAuJYy5PFVUyoi9Mlp4zNV4McjBMchBNIL5XXWcF5gXpt0rg2ImqRdiv/QVt1F
         7yDOKg3YGQYYu5/tEhbpTbP8Mj5QBzydq9xFhYcz8m20jEtFdKUZyBZxBBuWKY+pqyKE
         p91g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date;
        bh=6WhskxsObSNh1saZcmrK2YNjE5IY2TOs+LSquGXjHIU=;
        b=FvNGNEnoZvqCaVegUd/Y1ALwO1f3iBUjQ6KfyZdLYQ7MV2xqFQCKWQKJ3gC1VD0/NE
         blrDGQukxuh8fYWtuzXSBSH3WJC59LgfxM5uijlkO49Sz3SBYYSksGHRziSud7PCIqFl
         eq9Qpo0lA28pfRFjJG5NpXMTYnegXNU8DrpsuEshpYDlSDBzZ1P2ZX03TFbUDQUu2Dgm
         LwN+KBXiiyRsuz2MXtw4y/y5Z4LdeZMJ+fBrlO6k1Ts+qUmNE4VuBhk4kVAog57rjos2
         MNHry6JoaH2AscE6/0l86ehKWArI+OxfZWi0S9HqN9xoYij2pW/3al5l1omN+GaUzVzD
         nAqg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from outbound-smtp16.blacknight.com (outbound-smtp16.blacknight.com. [46.22.139.233])
        by mx.google.com with ESMTPS id x27si1634295edb.256.2019.04.24.05.21.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 05:21:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) client-ip=46.22.139.233;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of mgorman@techsingularity.net designates 46.22.139.233 as permitted sender) smtp.mailfrom=mgorman@techsingularity.net
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp16.blacknight.com (Postfix) with ESMTPS id 8F8B31C1C49
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 13:21:57 +0100 (IST)
Received: (qmail 20196 invoked from network); 24 Apr 2019 12:21:57 -0000
Received: from unknown (HELO techsingularity.net) (mgorman@techsingularity.net@[37.228.225.79])
  by 81.17.254.9 with ESMTPSA (AES256-SHA encrypted, authenticated); 24 Apr 2019 12:21:57 -0000
Date: Wed, 24 Apr 2019 13:21:56 +0100
From: Mel Gorman <mgorman@techsingularity.net>
To: Mike Rapoport <rppt@linux.ibm.com>
Cc: Christoph Hellwig <hch@infradead.org>,
	Matthew Wilcox <willy@infradead.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Mikulas Patocka <mpatocka@redhat.com>,
	James Bottomley <James.Bottomley@hansenpartnership.com>,
	linux-parisc@vger.kernel.org, linux-mm@kvack.org,
	Vlastimil Babka <vbabka@suse.cz>,
	LKML <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org
Subject: Re: DISCONTIGMEM is deprecated
Message-ID: <20190424122155.GT18914@techsingularity.net>
References: <20190419094335.GJ18914@techsingularity.net>
 <20190419140521.GI7751@bombadil.infradead.org>
 <20190421063859.GA19926@rapoport-lnx>
 <20190421132606.GJ7751@bombadil.infradead.org>
 <20190421211604.GN18914@techsingularity.net>
 <20190423071354.GB12114@infradead.org>
 <20190424113352.GA6278@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20190424113352.GA6278@rapoport-lnx>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 24, 2019 at 02:33:53PM +0300, Mike Rapoport wrote:
> On Tue, Apr 23, 2019 at 12:13:54AM -0700, Christoph Hellwig wrote:
> > On Sun, Apr 21, 2019 at 10:16:04PM +0100, Mel Gorman wrote:
> > > 32-bit NUMA systems should be non-existent in practice. The last NUMA
> > > system I'm aware of that was both NUMA and 32-bit only died somewhere
> > > between 2004 and 2007. If someone is running a 64-bit capable system in
> > > 32-bit mode with NUMA, they really are just punishing themselves for fun.
> > 
> > Can we mark it as BROKEN to see if someone shouts and then remove it
> > a year or two down the road?  Or just kill it off now..
> 
> How about making SPARSEMEM default for x86-32?
> 

While an improvement, I tend to agree with Christoph that marking it
BROKEN as a patch on top of this makes sense and wait to see who, if
anyone, screams. If it's quiet for long enough then we can remove it
entirely.

-- 
Mel Gorman
SUSE Labs

