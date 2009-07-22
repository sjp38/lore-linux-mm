Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 475206B0055
	for <linux-mm@kvack.org>; Wed, 22 Jul 2009 02:21:54 -0400 (EDT)
Message-ID: <4A66AEEC.1080600@cs.helsinki.fi>
Date: Wed, 22 Jul 2009 09:17:16 +0300
From: Pekka Enberg <penberg@cs.helsinki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] slub: release kobject if sysfs_create_group failed in
 sysfs_slab_add
References: <1248233333-22563-1-git-send-email-dfeng@redhat.com>
In-Reply-To: <1248233333-22563-1-git-send-email-dfeng@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Xiaotian Feng <dfeng@redhat.com>
Cc: cl@linux-foundation.org, linux-mm@kvack.org, linux-kernel.vger.kernel.org@redhat.com
List-ID: <linux-mm.kvack.org>

Xiaotian Feng wrote:
> When CONFIG_SLUB_DEBUG is enabled, sysfs_slab_add should unlink and put the
> kobject if sysfs_create_group failed. Otherwise, sysfs_slab_add returns error
> then free kmem_cache s, thus memory of s->kobj is leaked.
> 
> Acked-by: Christoph Lameter <cl@linux-foundation.org>
> Signed-off-by: Xiaotian Feng <dfeng@redhat.com>

Applied, thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
