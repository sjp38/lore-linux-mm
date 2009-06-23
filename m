Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 95BD36B005C
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 08:54:36 -0400 (EDT)
Date: Tue, 23 Jun 2009 21:55:16 +0900
From: Paul Mundt <lethal@linux-sh.org>
Subject: Re: [PATCH] asm-generic: add dummy pgprot_noncached()
Message-ID: <20090623125516.GA26674@linux-sh.org>
References: <20090614132845.17543.11882.sendpatchset@rx1.opensource.se> <20090615033240.GC31902@linux-sh.org> <20090622151537.2f8009f7.akpm@linux-foundation.org> <200906231441.37158.arnd@arndb.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <200906231441.37158.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: Arnd Bergmann <arnd@arndb.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, magnus.damm@gmail.com, linux-mm@kvack.org, jayakumar.lkml@gmail.com, Jesper Nilsson <jesper.nilsson@axis.com>, Chris Zankel <chris@zankel.net>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 23, 2009 at 02:41:36PM +0200, Arnd Bergmann wrote:
> From: Paul Mundt <lethal@linux-sh.org>
> 
> Most architectures now provide a pgprot_noncached(), the
> remaining ones can simply use an dummy default implementation,
> except for cris and xtensa, which should override the
> default appropriately.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Cc: Jesper Nilsson <jesper.nilsson@axis.com>
> Cc: Chris Zankel <chris@zankel.net>
> Cc: Magnus Damm <magnus.damm@gmail.com>

Signed-off-by: Paul Mundt <lethal@linux-sh.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
