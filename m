Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 5A2496B0031
	for <linux-mm@kvack.org>; Thu,  9 Jan 2014 02:16:40 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id w10so2818964pde.7
        for <linux-mm@kvack.org>; Wed, 08 Jan 2014 23:16:40 -0800 (PST)
Received: from LGEMRELSE7Q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id pt8si3001314pac.134.2014.01.08.23.16.37
        for <linux-mm@kvack.org>;
        Wed, 08 Jan 2014 23:16:38 -0800 (PST)
Date: Thu, 9 Jan 2014 16:16:56 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: possible regression on 3.13 when calling flush_dcache_page
Message-ID: <20140109071656.GA10290@lge.com>
References: <20131212143618.GJ12099@ldesroches-Latitude-E6320>
 <20131213015909.GA8845@lge.com>
 <20131216144343.GD9627@ldesroches-Latitude-E6320>
 <20131218072117.GA2383@lge.com>
 <20131220080851.GC16592@ldesroches-Latitude-E6320>
 <20131223224435.GD16592@ldesroches-Latitude-E6320>
 <20131224063837.GA27156@lge.com>
 <20140103145404.GC18002@ldesroches-Latitude-E6320>
 <20140106002648.GC696@lge.com>
 <20140106093408.GA2816@ldesroches-Latitude-E6320>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140106093408.GA2816@ldesroches-Latitude-E6320>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-mmc@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>

On Mon, Jan 06, 2014 at 10:34:09AM +0100, Ludovic Desroches wrote:
> On Mon, Jan 06, 2014 at 09:26:48AM +0900, Joonsoo Kim wrote:
> > On Fri, Jan 03, 2014 at 03:54:04PM +0100, Ludovic Desroches wrote:
> > > Hi,
> > > 
> > > On Tue, Dec 24, 2013 at 03:38:37PM +0900, Joonsoo Kim wrote:
> > > 
> > > [...]
> > > 
> > > > > > > > > I think that this commit may not introduce a bug. This patch remove one
> > > > > > > > > variable on slab management structure and replace variable name. So there
> > > > > > > > > is no functional change.
> > > 
> > > You are right, the commit given by git bisect was not the good one...
> > > Since I removed other patches done on top of it, I thought it really was
> > > this one but in fact it is 8456a64.
> > 
> > Okay. It seems more reasonable to me.
> > I guess that this is the same issue with following link.
> > http://lkml.org/lkml/2014/1/4/81
> > 
> > And, perhaps, that patch solves your problem. But I'm not sure that it is the
> > best solution for this problem. I should discuss with slab maintainers.
> 
> Yes this patch solves my problem.
> 
> > 
> > I will think about this problem more deeply and report the solution to you
> > as soon as possible.
> 
> Ok thanks.
> 

Hello,

That patch will be merged through Andrew's tree.
Use it to fix your problem :)

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
