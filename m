Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 48FD46B0005
	for <linux-mm@kvack.org>; Fri,  3 Aug 2018 18:34:04 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 2-v6so4012555plc.11
        for <linux-mm@kvack.org>; Fri, 03 Aug 2018 15:34:04 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f10-v6si5675692pgk.367.2018.08.03.15.34.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 03 Aug 2018 15:34:02 -0700 (PDT)
Date: Fri, 3 Aug 2018 15:33:57 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v3 2/2] slab: __GFP_ZERO is incompatible with a
 constructor
Message-ID: <20180803223357.GA23284@bombadil.infradead.org>
References: <20180411060320.14458-1-willy@infradead.org>
 <20180411060320.14458-3-willy@infradead.org>
 <alpine.DEB.2.20.1804110842560.3788@nuc-kabylake>
 <20180411192448.GD22494@bombadil.infradead.org>
 <alpine.DEB.2.20.1804111601090.7458@nuc-kabylake>
 <20180411235652.GA28279@bombadil.infradead.org>
 <alpine.DEB.2.20.1804120907100.11220@nuc-kabylake>
 <20180412142718.GA20398@bombadil.infradead.org>
 <20180412191322.GA21205@bombadil.infradead.org>
 <20180803212257.GA5922@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180803212257.GA5922@roeck-us.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: Christopher Lameter <cl@linux.com>, linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, linux-sh@vger.kernel.org

On Fri, Aug 03, 2018 at 02:22:57PM -0700, Guenter Roeck wrote:
> Hi,
> 
> On Thu, Apr 12, 2018 at 12:13:22PM -0700, Matthew Wilcox wrote:
> > From: Matthew Wilcox <mawilcox@microsoft.com>
> > 
> > __GFP_ZERO requests that the object be initialised to all-zeroes,
> > while the purpose of a constructor is to initialise an object to a
> > particular pattern.  We cannot do both.  Add a warning to catch any
> > users who mistakenly pass a __GFP_ZERO flag when allocating a slab with
> > a constructor.
> > 
> > Fixes: d07dbea46405 ("Slab allocators: support __GFP_ZERO in all allocators")
> > Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
> > Acked-by: Johannes Weiner <hannes@cmpxchg.org>
> > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> > Acked-by: Michal Hocko <mhocko@suse.com>
> 
> Seen with v4.18-rc7-139-gef46808 and v4.18-rc7-178-g0b5b1f9a78b5 when
> booting sh4 images in qemu:

Thanks!  It's under discussion here:

https://marc.info/?t=153301426900002&r=1&w=2

also reported here with a bogus backtrace:

https://marc.info/?l=linux-sh&m=153305755505935&w=2

Short version: It's a bug that's been present since 2009 and nobody
noticed until now.  And nobody's quite sure what the effect of this
bug is.
