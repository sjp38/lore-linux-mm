Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 31C926B0030
	for <linux-mm@kvack.org>; Tue, 20 Feb 2018 14:19:55 -0500 (EST)
Received: by mail-pl0-f72.google.com with SMTP id t2so8254803plr.15
        for <linux-mm@kvack.org>; Tue, 20 Feb 2018 11:19:55 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id u82si2649887pfg.389.2018.02.20.11.19.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 20 Feb 2018 11:19:53 -0800 (PST)
Date: Tue, 20 Feb 2018 11:19:51 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH] slab: fix /proc/slabinfo alignment
Message-ID: <20180220191951.GB12573@bombadil.infradead.org>
References: <BM1PR0101MB2083C73A6E7608B630CE4C26B1CF0@BM1PR0101MB2083.INDPRD01.PROD.OUTLOOK.COM>
 <alpine.DEB.2.20.1802200855300.28634@nuc-kabylake>
 <20180220150449.GF21243@bombadil.infradead.org>
 <alpine.DEB.2.20.1802201004480.29180@nuc-kabylake>
 <20180220161139.GH21243@bombadil.infradead.org>
 <alpine.DEB.2.20.1802201022540.29313@nuc-kabylake>
 <20180220183659.GA12573@bombadil.infradead.org>
 <alpine.DEB.2.20.1802201243220.30194@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1802201243220.30194@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: ? ? <mordorw@hotmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Feb 20, 2018 at 12:43:52PM -0600, Christopher Lameter wrote:
> On Tue, 20 Feb 2018, Matthew Wilcox wrote:
> 
> > In memcg_create_kmem_cache:
> >
> > 	s->name = kasprintf(GFP_KERNEL, "%s(%llu:%s)", a->name,
> > 				css->serial_nr, memcg_name_buf);
> >
> 
> But that creates the long name that shows up in /proc/slabinfo.

Yes.  People who enable cgroups get an ugly /proc/slabinfo.  I don't have
a solution to that, but at least those of us who don't enable cgroups will
no longer have:

drm_i915_gem_request    243    357    576    7    1 : tunables   54   27    8 : slabdata     51     51      0
fat_cache              0      0     32  124    1 : tunables  120   60    8 : slabdata      0      0      0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
