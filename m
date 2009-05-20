Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 4A1A56B0098
	for <linux-mm@kvack.org>; Wed, 20 May 2009 14:42:48 -0400 (EDT)
Subject: Re: [PATCH] mm/slub.c: Use print_hex_dump and remove unnecessary
 cast
From: Joe Perches <joe@perches.com>
In-Reply-To: <alpine.DEB.1.10.0905201420050.17511@qirst.com>
References: <1242840314-25635-1-git-send-email-joe@perches.com>
	 <alpine.DEB.1.10.0905201420050.17511@qirst.com>
Content-Type: text/plain
Date: Wed, 20 May 2009 11:42:46 -0700
Message-Id: <1242844966.22786.52.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, H Hartley Sweeten <hartleys@visionengravers.com>, linux-mm@kvack.org, Matt Mackall <mpm@selenic.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, David Rientjes <rientjes@google.com>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
List-ID: <linux-mm.kvack.org>

On Wed, 2009-05-20 at 14:23 -0400, Christoph Lameter wrote:
> This was discussed before.
> http://lkml.indiana.edu/hypermail/linux/kernel/0705.3/2671.html

You've got a good memory.

> Was hexdump changed?

It seems not.

> How does the output look after this change?

>From reading the code, the last column is unaligned.

I did submit a patch to fix hexdump once.
http://lkml.org/lkml/2007/12/6/304


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
