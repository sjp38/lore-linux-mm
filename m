Date: Tue, 17 Oct 2006 17:29:12 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Reduce CONFIG_ZONE_DMA ifdefs
In-Reply-To: <20061017170236.35dce526.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0610171725130.16180@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610171123160.14002@schroedinger.engr.sgi.com>
 <20061017170236.35dce526.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 17 Oct 2006, Andrew Morton wrote:

> That would give the thing a nice name, too - say, CONFIG_HAVE_ZONE_DMA.  It
> makes it obvious what's going on.

Ok.

> > -#ifdef CONFIG_ZONE_DMA
> > -#ifdef CONFIG_ZONE_DMA
> > -#ifdef CONFIG_ZONE_DMA
> 
> Only three.  Drat.

The problem is that some of the definitions like ZONE_DMA become invalid 
if CONFIG_ZONE_DMA is off and I think we need to keep that to make sure 
code does not refer to invalid zones. Around those areas the #ifdef cannot 
be dropped. The slab does not use ZONE_DMA directly. It only needs to deal 
with GFP_DMA. For that it works nicely.

I hope such a scheme would also allow the switching off of the bounce 
buffer logic and various other GFP_DMA related code all over the kernel. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
