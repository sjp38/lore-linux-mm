Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 3B6A66B004F
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 12:39:43 -0400 (EDT)
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 1F0D682C7CE
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 12:59:05 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.175.254])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id hgJo4Rv2RvGD for <linux-mm@kvack.org>;
	Fri, 17 Jul 2009 12:58:50 -0400 (EDT)
Received: from gentwo.org (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id 132B582C7C5
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 12:58:42 -0400 (EDT)
Date: Fri, 17 Jul 2009 12:39:11 -0400 (EDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [RFC PATCH] slub: release kobject if sysfs_create_group failed
 in sysfs_slab_add
In-Reply-To: <1247828908-13921-1-git-send-email-dfeng@redhat.com>
Message-ID: <alpine.DEB.1.10.0907171238550.11303@gentwo.org>
References: <1247828908-13921-1-git-send-email-dfeng@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Xiaotian Feng <dfeng@redhat.com>
Cc: penberg@cs.helsinki.fi, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


Acked-by: Christoph Lameter <cl@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
