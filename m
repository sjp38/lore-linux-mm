Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5DF6D6B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 21:00:43 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id fg1so72980468pad.1
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 18:00:43 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id l19si3744711pfb.167.2016.06.02.18.00.41
        for <linux-mm@kvack.org>;
        Thu, 02 Jun 2016 18:00:42 -0700 (PDT)
Date: Fri, 3 Jun 2016 10:01:29 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH] zsmalloc: zspage sanity check
Message-ID: <20160603010129.GC3304@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>

On Thu, Jun 02, 2016 at 09:25:19AM +0900, Minchan Kim wrote:
> On Wed, Jun 01, 2016 at 04:09:26PM +0200, Vlastimil Babka wrote:
> > On 06/01/2016 01:21 AM, Minchan Kim wrote:
> > 
> > [...]
> > 
> > > 
> > > Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> > > Signed-off-by: Minchan Kim <minchan@kernel.org>
> > 
> > I'm not that familiar with zsmalloc, so this is not a full review. I was
> > just curious how it's handling the movable migration API, and stumbled
> > upon some things pointed out below.
> > 
> > > @@ -252,16 +276,23 @@ struct zs_pool {
> > >   */
> > >  #define FULLNESS_BITS	2
> > >  #define CLASS_BITS	8
> > > +#define ISOLATED_BITS	3
> > > +#define MAGIC_VAL_BITS	8
> > >  
> > >  struct zspage {
> > >  	struct {
> > >  		unsigned int fullness:FULLNESS_BITS;
> > >  		unsigned int class:CLASS_BITS;
> > > +		unsigned int isolated:ISOLATED_BITS;
> > > +		unsigned int magic:MAGIC_VAL_BITS;
> > 
> > This magic seems to be only tested via VM_BUG_ON, so it's presence
> > should be also guarded by #ifdef DEBUG_VM, no?
> 
> Thanks for the point.
> 
> Then, I want to change it to BUG_ON because struct zspage corruption
> is really risky to work rightly and want to catch on it in real product
> which disable CONFIG_DEBUG_VM for a while until make the feature stable.

Andrew,

Please fold this patch into zsmalloc: page migration support.
Thanks!
