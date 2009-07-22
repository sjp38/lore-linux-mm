Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 8CEEA6B0105
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 08:24:36 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id DB97082C5B4
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 08:44:32 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id hfsNT3X4GxBy for <linux-mm@kvack.org>;
	Wed, 22 Jul 2009 08:44:28 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B493D82C5BA
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 08:44:18 -0400 (EDT)
Date: Wed, 22 Jul 2009 08:24:16 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] slub: sysfs_slab_remove should free kmem_cache when
 debug is enabled
In-Reply-To: <1248253437-23313-1-git-send-email-dfeng@redhat.com>
Message-ID: <alpine.DEB.1.10.0907220823580.7568@gentwo.org>
References: <1248253437-23313-1-git-send-email-dfeng@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Xiaotian Feng <dfeng@redhat.com>
Cc: penberg@cs.helsinki.fi, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


Acked-by: Christoph Lameer <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
