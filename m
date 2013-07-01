Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 2D0E76B0032
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 14:41:06 -0400 (EDT)
Date: Mon, 1 Jul 2013 18:41:04 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] slab: add kmalloc() to kernel API documentation
In-Reply-To: <1372177015-30492-1-git-send-email-michael.opdenacker@free-electrons.com>
Message-ID: <0000013f9b89c37f-5d9539bc-944c-4937-9b35-30cdd0fd18a3-000000@email.amazonses.com>
References: <1372177015-30492-1-git-send-email-michael.opdenacker@free-electrons.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Opdenacker <michael.opdenacker@free-electrons.com>
Cc: penberg@kernel.org, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 25 Jun 2013, Michael Opdenacker wrote:

> This patch is a proposed fix for this. It also removes the documentation
> for kmalloc() in include/linux/slob_def.h which isn't included to
> generate the documentation anyway. This way, kmalloc() is described
> in only one place.

Acked-by: Christoph Lameter <cl@linux.com>

Note that this will conflict with one of my pending patches that also
addresses one of these issues but this work is much more comprehensive.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
