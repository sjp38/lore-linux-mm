Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id B4A246B005D
	for <linux-mm@kvack.org>; Thu,  2 Aug 2012 16:45:43 -0400 (EDT)
Received: by yenr5 with SMTP id r5so10951630yen.14
        for <linux-mm@kvack.org>; Thu, 02 Aug 2012 13:45:42 -0700 (PDT)
Date: Thu, 2 Aug 2012 13:45:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: Common [03/19] Rename oops label
In-Reply-To: <20120802201532.052859834@linux.com>
Message-ID: <alpine.DEB.2.00.1208021343480.5454@chino.kir.corp.google.com>
References: <20120802201506.266817615@linux.com> <20120802201532.052859834@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Glauber Costa <glommer@parallels.com>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org, Joonsoo Kim <js1304@gmail.com>

On Thu, 2 Aug 2012, Christoph Lameter wrote:

> The label is actually used for successful exits so change the name.
> 

This patch is on top of common slab code where this label has a single 
reference and not for a successful exit until patch 11 in this series, so 
perhaps change it in the patch where this is true?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
