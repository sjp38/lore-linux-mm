Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C5DE96B0208
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 17:38:38 -0400 (EDT)
From: David Howells <dhowells@redhat.com>
In-Reply-To: <20100406213620.28251.90764.stgit@warthog.procyon.org.uk>
References: <20100406213620.28251.90764.stgit@warthog.procyon.org.uk>
Subject: Re: [PATCH] radix_tree_tag_get() is not as safe as the docs make out [ver #2]
Date: Tue, 06 Apr 2010 22:38:33 +0100
Message-ID: <28335.1270589913@redhat.com>
Sender: owner-linux-mm@kvack.org
Cc: dhowells@redhat.com, torvalds@osdl.org, akpm@linux-foundation.org, npiggin@suse.de, paulmck@linux.vnet.ibm.com, corbet@lwn.net, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


With this patch, I don't think I should need to modify FS-Cache.  There's the
possibility that we may think the page that we want to release is still being
written to the disk, but that should merely defer releasepage().

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
