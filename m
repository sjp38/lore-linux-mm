Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f181.google.com (mail-ig0-f181.google.com [209.85.213.181])
	by kanga.kvack.org (Postfix) with ESMTP id E7B396B0038
	for <linux-mm@kvack.org>; Wed,  7 Oct 2015 06:39:24 -0400 (EDT)
Received: by igcrk20 with SMTP id rk20so105692381igc.1
        for <linux-mm@kvack.org>; Wed, 07 Oct 2015 03:39:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 67si26799746iog.210.2015.10.07.03.39.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Oct 2015 03:39:24 -0700 (PDT)
Date: Wed, 7 Oct 2015 12:39:19 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [MM PATCH V4.1 5/6] slub: support for bulk free with SLUB
 freelists
Message-ID: <20151007123919.27a9c823@redhat.com>
In-Reply-To: <20151005212639.35932b6c@redhat.com>
References: <560ABE86.9050508@gmail.com>
	<20150930114255.13505.2618.stgit@canyon>
	<20151001151015.c59a1360c7720a257f655578@linux-foundation.org>
	<20151002114118.75aae2f9@redhat.com>
	<20151002154039.69f82bdc@redhat.com>
	<20151002145044.781c911ea98e3ea74ae5cf3b@linux-foundation.org>
	<20151005212639.35932b6c@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, Alexander Duyck <alexander.duyck@gmail.com>, netdev@vger.kernel.org, Arnaldo Carvalho de Melo <acme@redhat.com>, brouer@redhat.com


On Mon, 5 Oct 2015 21:26:39 +0200 Jesper Dangaard Brouer <brouer@redhat.com> wrote:
> On Fri, 2 Oct 2015 14:50:44 -0700 Andrew Morton <akpm@linux-foundation.org> wrote:
> 
[...] 
>  
> > Deleting the BUG altogether sounds the best solution.  As long as the
> > kernel crashes in some manner, we'll be able to work out what happened.
> > And it's cant-happen anyway, isn't it?
> 
> To me WARN_ON() seems like a good "documentation" if it does not hurt
> performance.  I don't think removing the WARN_ON() will improve
> performance, but I'm willing to actually test if it matters.

I tested removing BUG/WARN_ON altogether, and it gives slightly worse
performance. The icache-misses only increase approx 14% (not 112% as
before).  This, I'm willing to attribute to some code alignment issue.

Thus, let us just keep the WARN_ON() and move along.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
