Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id A7A9C6B0036
	for <linux-mm@kvack.org>; Mon, 16 Dec 2013 09:43:56 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id wm4so4843993obc.24
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 06:43:56 -0800 (PST)
Received: from eusmtp01.atmel.com (eusmtp01.atmel.com. [212.144.249.242])
        by mx.google.com with ESMTPS id co8si8274890oec.125.2013.12.16.06.43.53
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 16 Dec 2013 06:43:54 -0800 (PST)
Date: Mon, 16 Dec 2013 15:43:43 +0100
From: Ludovic Desroches <ludovic.desroches@atmel.com>
Subject: Re: possible regression on 3.13 when calling flush_dcache_page
Message-ID: <20131216144343.GD9627@ldesroches-Latitude-E6320>
References: <20131212143149.GI12099@ldesroches-Latitude-E6320>
 <20131212143618.GJ12099@ldesroches-Latitude-E6320>
 <20131213015909.GA8845@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20131213015909.GA8845@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-mmc@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Ludovic Desroches <ludovic.desroches@atmel.com>

Hello,

On Fri, Dec 13, 2013 at 10:59:09AM +0900, Joonsoo Kim wrote:
> On Thu, Dec 12, 2013 at 03:36:19PM +0100, Ludovic Desroches wrote:
> > fix mmc mailing list address error
> > 
> > On Thu, Dec 12, 2013 at 03:31:50PM +0100, Ludovic Desroches wrote:
> > > Hi,
> > > 
> > > With v3.13-rc3 I have an error when the atmel-mci driver calls
> > > flush_dcache_page (log at the end of the message).
> > > 
> > > Since I didn't have it before, I did a git bisect and the commit introducing
> > > the error is the following one:
> > > 
> > > 106a74e slab: replace free and inuse in struct slab with newly introduced active
> > > 
> > > I don't know if this commit has introduced a bug or if it has revealed a bug
> > > in the atmel-mci driver.
> 
> Hello,
> 
> I think that this commit may not introduce a bug. This patch remove one
> variable on slab management structure and replace variable name. So there
> is no functional change.
> 

If I have reverted this patch and other ones you did on top of it and
the issue disappear.

> I doubt that side-effect of this patch reveals a bug in other place.
> Side-effect is reduced memory usage for slab management structure. It would
> makes some slabs have more objects with more density since slab management
> structure is sometimes on the page for objects. So if it diminishes, more
> objects can be in the page.
> 
> Anyway, I will look at it more. If you have any progress, please let me know.

No progress at the moment.


Regards

Ludovic

> 
> Thanks.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
