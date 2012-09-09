Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id B721A6B005D
	for <linux-mm@kvack.org>; Sun,  9 Sep 2012 17:28:57 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so1698435pbb.14
        for <linux-mm@kvack.org>; Sun, 09 Sep 2012 14:28:57 -0700 (PDT)
Date: Sun, 9 Sep 2012 14:28:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 03/10] mm, slab: Remove silly function
 slab_buffer_size()
In-Reply-To: <1347137279-17568-3-git-send-email-elezegarcia@gmail.com>
Message-ID: <alpine.DEB.2.00.1209091428400.13346@chino.kir.corp.google.com>
References: <1347137279-17568-1-git-send-email-elezegarcia@gmail.com> <1347137279-17568-3-git-send-email-elezegarcia@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@kernel.org>

On Sat, 8 Sep 2012, Ezequiel Garcia wrote:

> This function is seldom used, and can be simply replaced with cachep->size.
> 
> Cc: Pekka Enberg <penberg@kernel.org>
> Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
