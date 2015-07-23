Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f54.google.com (mail-qg0-f54.google.com [209.85.192.54])
	by kanga.kvack.org (Postfix) with ESMTP id E85176B0260
	for <linux-mm@kvack.org>; Thu, 23 Jul 2015 07:09:25 -0400 (EDT)
Received: by qged69 with SMTP id d69so86292985qge.0
        for <linux-mm@kvack.org>; Thu, 23 Jul 2015 04:09:25 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w37si5330620qge.31.2015.07.23.04.09.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Jul 2015 04:09:24 -0700 (PDT)
Date: Thu, 23 Jul 2015 13:09:17 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 3/3] slub: build detached freelist with look-ahead
Message-ID: <20150723130917.6e46e7d0@redhat.com>
In-Reply-To: <20150723063423.GG4449@js1304-P5Q-DELUXE>
References: <20150715155934.17525.2835.stgit@devil>
	<20150715160212.17525.88123.stgit@devil>
	<20150716115756.311496af@redhat.com>
	<20150720025415.GA21760@js1304-P5Q-DELUXE>
	<20150720232817.05f08663@redhat.com>
	<alpine.DEB.2.11.1507210846060.27213@east.gentwo.org>
	<20150722012819.6b98a599@redhat.com>
	<20150723063423.GG4449@js1304-P5Q-DELUXE>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Alexander Duyck <alexander.duyck@gmail.com>, Hannes Frederic Sowa <hannes@stressinduktion.org>, brouer@redhat.com


On Thu, 23 Jul 2015 15:34:24 +0900 Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:

> On Wed, Jul 22, 2015 at 01:28:19AM +0200, Jesper Dangaard Brouer wrote:
> > On Tue, 21 Jul 2015 08:50:36 -0500 (CDT)
> > Christoph Lameter <cl@linux.com> wrote:
> > 
> > > On Mon, 20 Jul 2015, Jesper Dangaard Brouer wrote:
> > > 
> > > > Yes, I think it is merged... how do I turn off merging?
> > > 
> > > linux/Documentation/kernel-parameters.txt
> > > 
> > >         slab_nomerge    [MM]
> > >                         Disable merging of slabs with similar size. May be
> > >                         necessary if there is some reason to distinguish
> > >                         allocs to different slabs. Debug options disable
> > >                         merging on their own.
> > >                         For more information see Documentation/vm/slub.txt.
> > 
> > I was hoping I could define this per slub runtime.  Any chance this
> > would be made possible?
> 
> It's not possible to set/reset slab merge in runtime. Once merging
> happens, one slab could have objects from different kmem_caches so we
> can't separate it cleanly. Current best approach is to prevent merging
> when creating new kmem_cache by introducing new slab flag
> like as SLAB_NO_MERGE.

Yes, the best option would be a new flag (e.g. SLAB_NO_MERGE) when
creating the kmem_cache.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
