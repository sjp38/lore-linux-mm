Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 424696B014C
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 03:41:36 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id fb1so283026pad.17
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 00:41:35 -0800 (PST)
Received: from psmtp.com ([74.125.245.172])
        by mx.google.com with SMTP id dl5si1878681pbd.26.2013.11.07.00.41.34
        for <linux-mm@kvack.org>;
        Thu, 07 Nov 2013 00:41:34 -0800 (PST)
Date: Thu, 7 Nov 2013 09:41:29 +0100
From: Andreas Herrmann <andreas.herrmann@calxeda.com>
Subject: Re: [PATCH] mm/slub: Switch slub_debug kernel option to early_param
 to avoid boot panic
Message-ID: <20131107084129.GP5661@alberich>
References: <20131106184529.GB5661@alberich>
 <000001422ed8406b-14bef091-eee0-4e0e-bcdd-a8909c605910-000000@email.amazonses.com>
 <20131106195417.GK5661@alberich>
 <20131106203429.GL5661@alberich>
 <20131106211604.GM5661@alberich>
 <000001422f59e79e-ba0d30e2-fe7d-4e6f-9029-65dc5978fe60-000000@email.amazonses.com>
 <20131107082732.GN5661@alberich>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20131107082732.GN5661@alberich>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Thu, Nov 07, 2013 at 09:27:32AM +0100, Andreas Herrmann wrote:
> On Wed, Nov 06, 2013 at 04:38:10PM -0500, Christoph Lameter wrote:
> > On Wed, 6 Nov 2013, Andreas Herrmann wrote:
> > 
> > > Would be nice, if your patch is pushed upstream asap.
> > 
> > Ok so this is a
> > 
> > Tested-by: Andreas Herrmann <andreas.herrmann@calxeda.com>
> > 
> > I think?
> 
> Yes.

And for sake of completeness. Here is some debug output with a kernel
that had your "slub: Handle NULL parameter in kmem_cache_flags" patch
applied. And of course there were a couple of unnamed slabs:

  ...
         .bss : 0xc089fd80 - 0xc094cc4c   ( 692 kB)
  slub_debug_slabs (c2956a08): skbuff_fclone_cache, name (c06fc90c): kmem_cache_node
  slub_debug_slabs (c2956a08): skbuff_fclone_cache, name (c06fc91c): kmem_cache
a?? slub_debug_slabs (c2956a08): skbuff_fclone_cache, name (  (null)): (null)
  slub_debug_slabs (c2956a08): skbuff_fclone_cache, name (  (null)): (null)
  slub_debug_slabs (c2956a08): skbuff_fclone_cache, name (  (null)): (null)
  slub_debug_slabs (c2956a08): skbuff_fclone_cache, name (  (null)): (null)
  slub_debug_slabs (c2956a08): skbuff_fclone_cache, name (  (null)): (null)
  slub_debug_slabs (c2956a08): skbuff_fclone_cache, name (  (null)): (null)
  slub_debug_slabs (c2956a08): skbuff_fclone_cache, name (  (null)): (null)
  slub_debug_slabs (c2956a08): skbuff_fclone_cache, name (  (null)): (null)
  slub_debug_slabs (c2956a08): skbuff_fclone_cache, name (  (null)): (null)
  SLUB: HWalign=64, Order=0-3, MinObjects=0, CPUs=4, Nodes=1
  ...

The third one is wheree the panic happened w/o the fix.


Andreas

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
