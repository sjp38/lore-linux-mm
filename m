Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f172.google.com (mail-yk0-f172.google.com [209.85.160.172])
	by kanga.kvack.org (Postfix) with ESMTP id F2C516B0031
	for <linux-mm@kvack.org>; Tue, 14 Jan 2014 21:45:42 -0500 (EST)
Received: by mail-yk0-f172.google.com with SMTP id 200so210344ykr.3
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 18:45:42 -0800 (PST)
Received: from mail-yh0-x22c.google.com (mail-yh0-x22c.google.com [2607:f8b0:4002:c01::22c])
        by mx.google.com with ESMTPS id s22si3224742yha.26.2014.01.14.18.45.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 14 Jan 2014 18:45:42 -0800 (PST)
Received: by mail-yh0-f44.google.com with SMTP id f35so379117yha.3
        for <linux-mm@kvack.org>; Tue, 14 Jan 2014 18:45:41 -0800 (PST)
Date: Tue, 14 Jan 2014 18:45:38 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [RFC][PATCH 3/9] mm: page->pfmemalloc only used by slab/skb
In-Reply-To: <52D5B762.3090209@sr71.net>
Message-ID: <alpine.DEB.2.02.1401141842220.32645@chino.kir.corp.google.com>
References: <20140114180042.C1C33F78@viggo.jf.intel.com> <20140114180051.0181E467@viggo.jf.intel.com> <alpine.DEB.2.10.1401141348130.19618@nuc> <52D5B762.3090209@sr71.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>
Cc: Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, penberg@kernel.org

On Tue, 14 Jan 2014, Dave Hansen wrote:

> >> page->pfmemalloc does not deserve a spot in 'struct page'.  It is
> >> only used transiently _just_ after a page leaves the buddy
> >> allocator.
> > 
> > Why would we need to do this if we are removing the cmpxchg_double?
> 
> Why do we need the patch?
> 
> 'struct page' is a mess.  It's really hard to follow, and the space in
> the definition is a limited resource.  We should not waste that space on
> such a transient and unimportant value as pfmemalloc.
> 

I don't have any strong opinions on whether this patch is merged or not, 
but I'm not sure it's cleaner to do it with an accessor function that 
overloads page->index when its placement within the union inside 
struct page makes that obvious, nor is it good that the patch adds more 
code than it removes solely because it introduces those accessor 
functions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
