Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id C888E5F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 14:25:00 -0400 (EDT)
Date: Thu, 21 Oct 2010 13:24:57 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: slub: move slabinfo.c to tools/slub/slabinfo.c
In-Reply-To: <20101021111626.e3f214f5.randy.dunlap@oracle.com>
Message-ID: <alpine.DEB.2.00.1010211324190.24115@router.home>
References: <alpine.DEB.2.00.1010211300550.24115@router.home> <20101021111626.e3f214f5.randy.dunlap@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Oct 2010, Randy Dunlap wrote:

> Any special build/make rules needed, or just use straight 'gcc slabinfo.c -o slabinfo' ?
> (as listed in the source file :)

Just straight.

> Why move only this one source file from Documentation/vm/ ?
> There are several others there.

I felt somehow responsible since I placed it there.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
