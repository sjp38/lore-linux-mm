Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 60C506B13F0
	for <linux-mm@kvack.org>; Wed,  1 Feb 2012 17:05:22 -0500 (EST)
Received: by dadv6 with SMTP id v6so1597708dad.14
        for <linux-mm@kvack.org>; Wed, 01 Feb 2012 14:05:21 -0800 (PST)
Date: Wed, 1 Feb 2012 14:05:19 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Slub cleanup 5/9] slub: new_slab_objects() can also get objects
 from partial list
In-Reply-To: <20120123201708.312262597@linux.com>
Message-ID: <alpine.DEB.2.00.1202011405090.10854@chino.kir.corp.google.com>
References: <20120123201646.924319545@linux.com> <20120123201708.312262597@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org

On Mon, 23 Jan 2012, Christoph Lameter wrote:

> Moving the attempt to get a slab page from the partial lists simplifies
> __slab_alloc which is rather complicated.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
