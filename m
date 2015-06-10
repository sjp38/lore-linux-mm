Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id DB3146B0032
	for <linux-mm@kvack.org>; Wed, 10 Jun 2015 00:47:54 -0400 (EDT)
Received: by igbsb11 with SMTP id sb11so25589355igb.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 21:47:54 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0195.hostedemail.com. [216.40.44.195])
        by mx.google.com with ESMTP id a3si8048197icv.24.2015.06.09.21.47.54
        for <linux-mm@kvack.org>;
        Tue, 09 Jun 2015 21:47:54 -0700 (PDT)
Message-ID: <1433911671.2730.102.camel@perches.com>
Subject: Re: [RFC][PATCH 0/5] do not dereference NULL pools in pools'
 destroy() functions
From: Joe Perches <joe@perches.com>
Date: Tue, 09 Jun 2015 21:47:51 -0700
In-Reply-To: <20150609191755.867a36c3.akpm@linux-foundation.org>
References: <1433851493-23685-1-git-send-email-sergey.senozhatsky@gmail.com>
	 <20150609142523.b717dba6033ee08de997c8be@linux-foundation.org>
	 <alpine.DEB.2.11.1506092008220.3300@east.gentwo.org>
	 <20150609185150.8c9fed8d.akpm@linux-foundation.org>
	 <alpine.DEB.2.11.1506092056570.6964@east.gentwo.org>
	 <20150609191755.867a36c3.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Minchan Kim <minchan@kernel.org>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, sergey.senozhatsky.work@gmail.com

On Tue, 2015-06-09 at 19:17 -0700, Andrew Morton wrote:
> On Tue, 9 Jun 2015 21:00:58 -0500 (CDT) Christoph Lameter <cl@linux.com> wrote:
> > On Tue, 9 Jun 2015, Andrew Morton wrote:
> > > > Why do this at all?
> > Did some grepping and I did see some call sites that do this but the
> > majority has to do other processing as well.
> > 
> > 200 call sites? Do we have that many uses of caches? Typical prod system
> > have ~190 caches active and the merging brings that down to half of that.
> I didn't try terribly hard.
> z:/usr/src/linux-4.1-rc7> grep -r -C1 kmem_cache_destroy .  | grep "if [(]" | wc -l
> 158
> 
> It's a lot, anyway.

Yeah.

$ git grep -E -B1 -w "(kmem_cache|mempool|dma_pool)_destroy" *| \
  grep -P "\bif\s*\(" | wc -l
268


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
