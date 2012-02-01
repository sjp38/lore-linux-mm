Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id A124B6B13F0
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 16:55:01 -0500 (EST)
Received: by dadv6 with SMTP id v6so1589094dad.14
        for <linux-mm@kvack.org>; Wed, 01 Feb 2012 13:55:01 -0800 (PST)
Date: Wed, 1 Feb 2012 13:54:59 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Slub cleanup 2/9] slub: Add frozen check in __slab_alloc
In-Reply-To: <20120123201706.547465637@linux.com>
Message-ID: <alpine.DEB.2.00.1202011354470.10854@chino.kir.corp.google.com>
References: <20120123201646.924319545@linux.com> <20120123201706.547465637@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org

On Mon, 23 Jan 2012, Christoph Lameter wrote:

> Verify that objects returned from __slab_alloc come from slab pages
> in the correct state.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
