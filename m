Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id D95DD6B0081
	for <linux-mm@kvack.org>; Tue, 15 May 2012 02:26:14 -0400 (EDT)
Received: by dakp5 with SMTP id p5so10055791dak.14
        for <linux-mm@kvack.org>; Mon, 14 May 2012 23:26:14 -0700 (PDT)
Date: Mon, 14 May 2012 23:26:11 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slub: remove unused argument of init_kmem_cache_node()
In-Reply-To: <1336665047-22205-1-git-send-email-js1304@gmail.com>
Message-ID: <alpine.DEB.2.00.1205142326000.19403@chino.kir.corp.google.com>
References: <1336665047-22205-1-git-send-email-js1304@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 11 May 2012, Joonsoo Kim wrote:

> We don't use the argument since commit 3b89d7d881a1dbb4da158f7eb5d6b3ceefc72810
> ('slub: move min_partial to struct kmem_cache'), so remove it
> 
> Signed-off-by: Joonsoo Kim <js1304@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
