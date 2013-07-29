Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 15EC76B0031
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 18:10:43 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id wy7so5174117pbc.3
        for <linux-mm@kvack.org>; Mon, 29 Jul 2013 15:10:42 -0700 (PDT)
Date: Mon, 29 Jul 2013 15:10:40 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: page_alloc: fix comment get_page_from_freelist
In-Reply-To: <1374681121-1340-1-git-send-email-waydi1@gmail.com>
Message-ID: <alpine.DEB.2.02.1307291510170.29771@chino.kir.corp.google.com>
References: <1374681121-1340-1-git-send-email-waydi1@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: SeungHun Lee <waydi1@gmail.com>
Cc: linux-mm@kvack.org

On Thu, 25 Jul 2013, SeungHun Lee wrote:

> cpuset_zone_allowed is changed to cpuset_zone_allowed_softwall
> 
> and the comment is moved to __cpuset_node_allowed_softwall.
> 
> So fix this comment.
> 
> Signed-off-by: SeungHun Lee <waydi1@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

I forgot to change this comment while renaming the function, thanks for 
catching it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
