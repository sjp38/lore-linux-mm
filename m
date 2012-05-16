Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id E49FB6B0092
	for <linux-mm@kvack.org>; Wed, 16 May 2012 02:46:20 -0400 (EDT)
Received: by lahi5 with SMTP id i5so435567lah.14
        for <linux-mm@kvack.org>; Tue, 15 May 2012 23:46:17 -0700 (PDT)
Date: Wed, 16 May 2012 09:46:13 +0300 (EEST)
From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH] slub: remove unused argument of init_kmem_cache_node()
In-Reply-To: <alpine.DEB.2.00.1205142326000.19403@chino.kir.corp.google.com>
Message-ID: <alpine.LFD.2.02.1205160946020.2249@tux.localdomain>
References: <1336665047-22205-1-git-send-email-js1304@gmail.com> <alpine.DEB.2.00.1205142326000.19403@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <js1304@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 14 May 2012, David Rientjes wrote:
> On Fri, 11 May 2012, Joonsoo Kim wrote:
> 
> > We don't use the argument since commit 3b89d7d881a1dbb4da158f7eb5d6b3ceefc72810
> > ('slub: move min_partial to struct kmem_cache'), so remove it
> > 
> > Signed-off-by: Joonsoo Kim <js1304@gmail.com>
> 
> Acked-by: David Rientjes <rientjes@google.com>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
