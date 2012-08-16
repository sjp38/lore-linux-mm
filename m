Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 2777F6B005D
	for <linux-mm@kvack.org>; Thu, 16 Aug 2012 18:32:27 -0400 (EDT)
Date: Thu, 16 Aug 2012 22:32:25 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [patch] mm, slab: remove dflags
In-Reply-To: <alpine.DEB.2.00.1208161225480.28427@chino.kir.corp.google.com>
Message-ID: <000001393190efa8-08cba91b-1bf6-4d31-8b0c-f3864bbe26b0-000000@email.amazonses.com>
References: <alpine.DEB.2.00.1208161225480.28427@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org

On Thu, 16 Aug 2012, David Rientjes wrote:

> cachep->dflags is never referenced, so remove it.

Acked-by: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
