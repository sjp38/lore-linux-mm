Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 595DF6B004F
	for <linux-mm@kvack.org>; Thu,  8 Dec 2011 02:50:54 -0500 (EST)
Received: by ghbg19 with SMTP id g19so1604932ghb.14
        for <linux-mm@kvack.org>; Wed, 07 Dec 2011 23:50:53 -0800 (PST)
Date: Wed, 7 Dec 2011 23:50:50 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/1] vmalloc: Remove static declaration of va from
 __get_vm_area_node
In-Reply-To: <1323330621-31254-1-git-send-email-consul.kautuk@gmail.com>
Message-ID: <alpine.DEB.2.00.1112072350380.28419@chino.kir.corp.google.com>
References: <1323330621-31254-1-git-send-email-consul.kautuk@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joe Perches <joe@perches.com>, Minchan Kim <minchan.kim@gmail.com>, David Vrabel <david.vrabel@citrix.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 8 Dec 2011, Kautuk Consul wrote:

> Static storage is not required for the struct vmap_area in
> __get_vm_area_node.
> 
> Removing "static" to store this variable on the stack instead.
> 
> Signed-off-by: Kautuk Consul <consul.kautuk@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
