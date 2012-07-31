Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010asp102.postini.com [74.125.245.222])
	by kanga.kvack.org (Postfix) with SMTP id 13A636B00C3
	for <linux-mm@kvack.org>; Tue, 31 Jul 2012 13:26:33 -0400 (EDT)
Date: Tue, 31 Jul 2012 11:52:11 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: Common [13/20] Extract a common function for
 kmem_cache_destroy
In-Reply-To: <50180AC0.1040403@parallels.com>
Message-ID: <alpine.DEB.2.00.1207311151430.32295@router.home>
References: <20120601195245.084749371@linux.com> <20120601195307.063633659@linux.com> <5017C90E.7060706@parallels.com> <alpine.DEB.2.00.1207310910580.32295@router.home> <5017E8C3.1040004@parallels.com> <alpine.DEB.2.00.1207310942090.32295@router.home>
 <5017EFE9.1080804@parallels.com> <alpine.DEB.2.00.1207311129520.32295@router.home> <50180AC0.1040403@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Joonsoo Kim <js1304@gmail.com>

On Tue, 31 Jul 2012, Glauber Costa wrote:

> Ok, maybe this is due to a difference in our setup. I needed to
> explicitly create and destroy caches to trigger it.
>
> But as long as it is fixed, it doesn't really matter =)

Ok I will see if I can just send the patches on this issue today.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
