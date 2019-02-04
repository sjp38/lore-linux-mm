Return-Path: <SRS0=bR/Z=QL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.3 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS,USER_AGENT_MUTT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B67B5C282C4
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 22:26:54 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 682A120823
	for <linux-mm@archiver.kernel.org>; Mon,  4 Feb 2019 22:26:54 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="gW9dulqu"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 682A120823
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 160728E0061; Mon,  4 Feb 2019 17:26:54 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 110518E001C; Mon,  4 Feb 2019 17:26:54 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id F40A18E0061; Mon,  4 Feb 2019 17:26:53 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id B2A038E001C
	for <linux-mm@kvack.org>; Mon,  4 Feb 2019 17:26:53 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id q14so904416pll.15
        for <linux-mm@kvack.org>; Mon, 04 Feb 2019 14:26:53 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:from:to:cc:subject
         :message-id:references:mime-version:content-disposition:in-reply-to
         :user-agent;
        bh=jj1JYX7y+74CHIdlUOR3JdF6uekR7wdvegk+RbOB8ek=;
        b=Z+SP5PAMQc8ziK2HuO/rYm8fC04hD5RXgwmkT/BHhHucsIvKbTOgJkCNOT9PTm3RhM
         nwe2UkcrBTqiHchzw3OR6pubp6nLxKGcsZaYCqzIQ7MqdZq2EHUJmtudH8EIlb4P43d6
         wa69R7E7PwTVK6P54LgKpFDYgwMr7kBCig0m/NPVwTCL5bHkGwNwCTIuCakLNoC7oWi6
         77UGKH/QSAg8HbUQw4yqXHkIOsqyofea0DG1P1Xi9Dt5SQvsH3OBaZseIbZw6l8HdjU5
         m/KXTuPIZbtAw+XPOPx2jOkmht4cQCUrQRIUYi3x1J/GaMncy4/zGPErLemhoyPalSA6
         fD5Q==
X-Gm-Message-State: AHQUAua9g6Q2iIEpOKk6QDDHeDeOQtNZ1FVcbvWdbQMHlOGpQ+HzdFSz
	c9Y63lpP+2a5/Uga5ngWrZ9gw1QnvXR4oScI+GoFzmVXAC+9ASGpp2HEZIV3wWGfJ4v0BXABwTv
	ZhH4OvGyC3jsgFYv38QTB9hfn1WM4oil9UNZAig6KSxhlOoKgexBS5festN0/0sMDMg==
X-Received: by 2002:a63:1013:: with SMTP id f19mr1581570pgl.38.1549319213286;
        Mon, 04 Feb 2019 14:26:53 -0800 (PST)
X-Google-Smtp-Source: AHgI3Iba01Bx7foCdSDqzA+JgjUSKGIyU0ubI9jr6gSN44+KvJPD9nFj6h3q8soBlPYaI0TwRg6u
X-Received: by 2002:a63:1013:: with SMTP id f19mr1581528pgl.38.1549319212467;
        Mon, 04 Feb 2019 14:26:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549319212; cv=none;
        d=google.com; s=arc-20160816;
        b=TIP7vluld3TkPexBnJe1gc4AIwWjDv1j6cDskVY+VMGUuoDBuD51qf/KW71ICGWnBu
         K1oZVb49sjd9EoygoVWkYKiTe3UJwZ0OYvOxtAWoByzow0HzoSUoQv92RCnJinwdlOl9
         ddyx4M6ohnPkAEy8S2pbnZwhsazPualtROySK3VPYYALjzRWOFiOWyjM6xNKfOAThHtY
         tpdRO6a4Lk16BgvTQs+lsiSogRei/7G7CD5p38j9b9UJ9qr1qVrf9jv1cdFB8Fo4IBHf
         jqj0wc7L7DlhGUZgibhc9SMovlnCyINOlKuDbn2DBklLRH1FMVQU5VQaBdSimP/LaOo0
         N9Wg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-disposition:mime-version:references
         :message-id:subject:cc:to:from:date:dkim-signature;
        bh=jj1JYX7y+74CHIdlUOR3JdF6uekR7wdvegk+RbOB8ek=;
        b=GsJ4rOxCx2E1gMSmg0G7VvAmFGrg/7VMKgLeGPeYXrjLLbD21UAzr7TliT32+ZUARa
         RFMbsO93ZYzvdDtjbHNQ240C+BQQ3PAHkH3hUeA1lGuQbyDSpLHJVwQIeicU4gtAKhth
         4vQ/32k0iZcHFZja7ooyr0ZkKV4+aeMr0Fr/cW5IPObJc3k4iV3lj23sMAQZoIWioma3
         lWj8SsLnNznEOVOWA3QjO4n+qZDwn8JaLjsP9jixfhWLDcsHWaKjKxlSqeftk5PW5LKh
         aMo1/jpFJW8Mk0rEWlNP4v3fNKWYbLUhN6ExA3YvOZDnRgG4GafUFlgH31dc7nJwhmYg
         pj+w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gW9dulqu;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v141si1417020pfc.260.2019.02.04.14.26.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 04 Feb 2019 14:26:52 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=gW9dulqu;
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=In-Reply-To:Content-Type:MIME-Version
	:References:Message-ID:Subject:Cc:To:From:Date:Sender:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=jj1JYX7y+74CHIdlUOR3JdF6uekR7wdvegk+RbOB8ek=; b=gW9dulquY4Hag/NN4k7qBuCcV
	81lWTP8IF2ekbw6RlOJVpMkL9USVVseGwIL07tZSyOJOkN0wBLnVZZFOOs+ckq7DQpLZL9OSMDrah
	aUr4pYtTV/eQLFzr/Gv+e29piMpIEZtMoG9bGoR7iByyRYQAE8TXIBpncb0kPxhjxIVlDMD7gQMyY
	vtgJqt1pIrCWqxpEEMa9VAq+1N+YuENFnpUgth5Qhiy7DipMcDMn2YcUG4qjZbvk/GCdy2YLR/lbb
	e+NLZ3OiwQToaPaaU4ecethwgeXFZo1xC+LTef4TLm7JUqUSYTZzHDVWdsNZqTQxD6J0Fy7Tgziek
	OY81qZc/g==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gqmhP-0005eK-4r; Mon, 04 Feb 2019 22:26:43 +0000
Date: Mon, 4 Feb 2019 14:26:42 -0800
From: Matthew Wilcox <willy@infradead.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"Huang, Ying" <ying.huang@intel.com>,
	Daniel Jordan <daniel.m.jordan@oracle.com>,
	dan.carpenter@oracle.com, andrea.parri@amarulasolutions.com,
	dave.hansen@linux.intel.com, sfr@canb.auug.org.au, osandov@fb.com,
	tj@kernel.org, ak@linux.intel.com, linux-mm@kvack.org,
	kernel-janitors@vger.kernel.org, paulmck@linux.ibm.com,
	stern@rowland.harvard.edu, peterz@infradead.org,
	will.deacon@arm.com
Subject: Re: About swapoff race patch  (was Re: [PATCH] mm, swap: bounds
 check swap_info accesses to avoid NULL derefs)
Message-ID: <20190204222642.GF21860@bombadil.infradead.org>
References: <20190114222529.43zay6r242ipw5jb@ca-dmjordan1.us.oracle.com>
 <20190115002305.15402-1-daniel.m.jordan@oracle.com>
 <20190129222622.440a6c3af63c57f0aa5c09ca@linux-foundation.org>
 <87tvhpy22q.fsf_-_@yhuang-dev.intel.com>
 <20190131124655.96af1eb7e2f7bb0905527872@linux-foundation.org>
 <alpine.LSU.2.11.1902041257390.4682@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1902041257390.4682@eggly.anvils>
User-Agent: Mutt/1.9.2 (2017-12-15)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 04, 2019 at 01:37:00PM -0800, Hugh Dickins wrote:
> On Thu, 31 Jan 2019, Andrew Morton wrote:
> > On Thu, 31 Jan 2019 10:48:29 +0800 "Huang\, Ying" <ying.huang@intel.com> wrote:
> > > Andrew Morton <akpm@linux-foundation.org> writes:
> > > > mm-swap-fix-race-between-swapoff-and-some-swap-operations.patch is very
> > > > stuck so can you please redo this against mainline?
> > 
> > I have no evidence that it has been reviewed, for a start.  I've asked
> > Hugh to look at it.
> 
> I tried at the weekend.  Usual story: I don't like it at all, the
> ever-increasing complexity there, but certainly understand the need
> for that fix, and have not managed to think up anything better -
> and now I need to switch away, sorry.
> 
> The multiple dynamically allocated and freed swapper address spaces
> have indeed broken what used to make it safe.  If those imaginary
> address spaces did not have to be virtually contiguous, I'd say
> cache them and reuse them, instead of freeing.  But I don't see
> how to do that as it stands.
> 
> find_get_page(swapper_address_space(entry), swp_offset(entry)) has
> become an unsafe construct, where it used to be safe against corrupted
> page tables.  Maybe we don't care so much about crashing on corrupted
> page tables nowadays (I haven't heard recent complaints), and I think
> Huang is correct that lookup_swap_cache() and __read_swap_cache_async()
> happen to be the only instances that need to be guarded against swapoff
> (the others are working with page table locked).
> 
> The array of arrays of swapper spaces is all just to get a separate
> lock for separate extents of the swapfile: I wonder whether Matthew has
> anything in mind for that in XArray (I think Peter once got it working
> in radix-tree, but the overhead not so good).

Hi Hugh, thanks for putting me on the cc.

I've certainly noticed what's been going on with the swapper code, but
I've generally had a lack of tuits (round or otherwise) to really dig in
and figure out what's going on.  I've had some ideas about embedding a
spinlock in each leaf node (giving one lock per 64 slots), but I know I've
got about 800 things that I've actually promised to do ahead of looking
at doing that.

I have a suspicion that the swapper code could probably be replaced with
an allocating XArray (like the IDR) and it doesn't really need to be a
full on address_space, but I'm probably wrong because I haven't studied
the swap code in depth.

