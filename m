Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 9F2F86B00BB
	for <linux-mm@kvack.org>; Tue, 11 Sep 2012 05:47:44 -0400 (EDT)
Date: Tue, 11 Sep 2012 17:47:38 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH] idr: Rename MAX_LEVEL to MAX_ID_LEVEL
Message-ID: <20120911094738.GA32509@localhost>
References: <20120910131426.GA12431@localhost>
 <1347352069.14488.12.camel@thorin>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1347352069.14488.12.camel@thorin>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bernd Petrovitsch <bernd@petrovitsch.priv.at>
Cc: Andrew Morton <akpm@linux-foundation.org>, Glauber Costa <glommer@parallels.com>, kernel-janitors@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>

Hi Bernd,

> > -#define MAX_LEVEL (MAX_ID_SHIFT + IDR_BITS - 1) / IDR_BITS
> > +#define MAX_ID_LEVEL (MAX_ID_SHIFT + IDR_BITS - 1) / IDR_BITS
> 
> And while you are it: Please add '(' and ')' around it as in 
> 
> #define MAX_ID_LEVEL ((MAX_ID_SHIFT + IDR_BITS - 1) / IDR_BITS)

Good idea. Done.

> 
> >  /* Number of id_layer structs to leave in free list */
> > -#define IDR_FREE_MAX MAX_LEVEL + MAX_LEVEL
> > +#define IDR_FREE_MAX MAX_ID_LEVEL + MAX_ID_LEVEL
> #define IDR_FREE_MAX (MAX_ID_LEVEL + MAX_ID_LEVEL)
> 
> For starters (sleeping in "cpp-101";-): People may use it as in
> "IDR_FREE_MAX * 2".
> And I didn't look into that file - that should be changed everywhere in
> that way.

Sure. It's the only place that need change.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
