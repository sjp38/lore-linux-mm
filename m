Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id BBF736B0031
	for <linux-mm@kvack.org>; Thu, 12 Sep 2013 10:21:18 -0400 (EDT)
Date: Thu, 12 Sep 2013 14:21:17 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 07/16] slab: overloading the RCU head over the LRU for
 RCU free
In-Reply-To: <20130912065549.GC8055@lge.com>
Message-ID: <00000141128c2585-743bf539-ce6f-45ef-a68e-3b4547a2af07-000000@email.amazonses.com>
References: <1377161065-30552-1-git-send-email-iamjoonsoo.kim@lge.com> <1377161065-30552-8-git-send-email-iamjoonsoo.kim@lge.com> <000001410d765d3a-0f3f8df2-dccb-455a-a929-f1fd018700d2-000000@email.amazonses.com> <20130912065549.GC8055@lge.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Pekka Enberg <penberg@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 12 Sep 2013, Joonsoo Kim wrote:

> On Wed, Sep 11, 2013 at 02:39:22PM +0000, Christoph Lameter wrote:
> > On Thu, 22 Aug 2013, Joonsoo Kim wrote:
> >
> > > With build-time size checking, we can overload the RCU head over the LRU
> > > of struct page to free pages of a slab in rcu context. This really help to
> > > implement to overload the struct slab over the struct page and this
> > > eventually reduce memory usage and cache footprint of the SLAB.
> >
> > Looks fine to me. Can you add the rcu_head to the struct page union? This
> > kind of overload is used frequently elsewhere as well. Then cleanup other
> > cases of such uses (such as in SLUB).
>
> Okay. But I will implement it seprately because I don't know where the cases
> are now and some inverstigation would be needed.

Do it just for this case. The others can be done later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
