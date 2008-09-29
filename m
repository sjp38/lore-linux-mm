From: David Howells <dhowells@redhat.com>
In-Reply-To: <48DD073D.9080109@linux-foundation.org>
References: <48DD073D.9080109@linux-foundation.org> <15178.1222381876@redhat.com>
Subject: Re: A question about alloc_pages()
Date: Mon, 29 Sep 2008 14:21:11 +0100
Message-ID: <31462.1222694471@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: dhowells@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter <cl@linux-foundation.org> wrote:

> Must be a bug.

Seems I wasn't returning the blocks of pages correctly: the first page needed
its page_count() setting to 1 and the an order-N sized page block had to be
order-N aligned before calling __free_pages().  However, if you don't turn on
CONFIG_DEBUG_VM, it appears to work, but produces some odd effects.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
