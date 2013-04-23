Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 96CBE6B0034
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 11:51:15 -0400 (EDT)
Date: Tue, 23 Apr 2013 15:51:10 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [Patch v2] mm: slab: Verify the nodeid passed to
 ____cache_alloc_node
In-Reply-To: <1014891011.990074.1366727496599.JavaMail.root@redhat.com>
Message-ID: <0000013e37976a8c-6e13fd72-1ae9-49e3-97fa-0fbb4dd3104d-000000@email.amazonses.com>
References: <1014891011.990074.1366727496599.JavaMail.root@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aaron Tomlin <atomlin@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, penberg@kernel.org, Rik <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>

On Tue, 23 Apr 2013, Aaron Tomlin wrote:

> This patch is in response to BZ#42967 [1].
> Using VM_BUG_ON so it's used only when CONFIG_DEBUG_VM is set,
> given that ____cache_alloc_node() is a hot code path.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
