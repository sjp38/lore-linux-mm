Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 1BE4B6B0032
	for <linux-mm@kvack.org>; Thu, 11 Jun 2015 13:38:12 -0400 (EDT)
Received: by padev16 with SMTP id ev16so7304098pad.0
        for <linux-mm@kvack.org>; Thu, 11 Jun 2015 10:38:11 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id hn9si1795903pdb.133.2015.06.11.10.38.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 11 Jun 2015 10:38:11 -0700 (PDT)
Date: Thu, 11 Jun 2015 10:40:56 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC][PATCH 0/5] do not dereference NULL pools in pools'
 destroy() functions
Message-Id: <20150611104056.5d2122dd.akpm@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.11.1506111212530.18426@east.gentwo.org>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
	<20150609142523.b717dba6033ee08de997c8be@linux-foundation.org>
	<alpine.DEB.2.11.1506092008220.3300@east.gentwo.org>
	<20150609185150.8c9fed8d.akpm@linux-foundation.org>
	<alpine.DEB.2.11.1506092056570.6964@east.gentwo.org>
	<20150609191755.867a36c3.akpm@linux-foundation.org>
	<alpine.DEB.2.11.1506111212530.18426@east.gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com, Joe Perches <joe@perches.com>

On Thu, 11 Jun 2015 12:26:11 -0500 (CDT) Christoph Lameter <cl@linux.com> wrote:

> On Tue, 9 Jun 2015, Andrew Morton wrote:
> 
> > > > More than half of the kmem_cache_destroy() callsites are declining that
> > > > value by open-coding the NULL test.  That's reality and we should recognize
> > > > it.
> > >
> > > Well that may just indicate that we need to have a look at those
> > > callsites and the reason there to use a special cache at all.
> >
> > This makes no sense.  Go look at the code.
> > drivers/staging/lustre/lustre/llite/super25.c, for example.  It's all
> > in the basic unwind/recover/exit code.
> 
> That is screwed up code. I'd do that without the checks simply with a
> series of kmem_cache_destroys().

So go and review some of the many other callers which do this.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
