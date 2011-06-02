Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id D341F6B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2011 13:12:16 -0400 (EDT)
Received: from hpaq1.eem.corp.google.com (hpaq1.eem.corp.google.com [172.25.149.1])
	by smtp-out.google.com with ESMTP id p52HC7oA027610
	for <linux-mm@kvack.org>; Thu, 2 Jun 2011 10:12:07 -0700
Received: from pwi16 (pwi16.prod.google.com [10.241.219.16])
	by hpaq1.eem.corp.google.com with ESMTP id p52HC4pO017089
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 2 Jun 2011 10:12:05 -0700
Received: by pwi16 with SMTP id 16so613382pwi.7
        for <linux-mm@kvack.org>; Thu, 02 Jun 2011 10:12:03 -0700 (PDT)
Date: Thu, 2 Jun 2011 10:12:01 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] SLAB: Record actual last user of freed objects.
In-Reply-To: <1306999002-29738-1-git-send-email-ssouhlal@FreeBSD.org>
Message-ID: <alpine.DEB.2.00.1106021011510.18350@chino.kir.corp.google.com>
References: <1306999002-29738-1-git-send-email-ssouhlal@FreeBSD.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suleiman Souhlal <ssouhlal@freebsd.org>
Cc: penberg@kernel.org, suleiman@google.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org, mpm@selenic.com

On Thu, 2 Jun 2011, Suleiman Souhlal wrote:

> Currently, when using CONFIG_DEBUG_SLAB, we put in kfree() or
> kmem_cache_free() as the last user of free objects, which is not
> very useful, so change it to the caller of those functions instead.
> 
> Signed-off-by: Suleiman Souhlal <suleiman@google.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
