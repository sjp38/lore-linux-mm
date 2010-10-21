Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1716D5F0040
	for <linux-mm@kvack.org>; Thu, 21 Oct 2010 14:17:54 -0400 (EDT)
Date: Thu, 21 Oct 2010 11:16:26 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: Re: slub: move slabinfo.c to tools/slub/slabinfo.c
Message-Id: <20101021111626.e3f214f5.randy.dunlap@oracle.com>
In-Reply-To: <alpine.DEB.2.00.1010211300550.24115@router.home>
References: <alpine.DEB.2.00.1010211300550.24115@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Oct 2010 13:01:56 -0500 (CDT) Christoph Lameter wrote:

> We now have a tools directory for these things.
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>


Any special build/make rules needed, or just use straight 'gcc slabinfo.c -o slabinfo' ?
(as listed in the source file :)


Why move only this one source file from Documentation/vm/ ?
There are several others there.


> ---
>  Documentation/vm/slabinfo.c | 1364 --------------------------------------------
>  tools/slub/slabinfo.c       | 1364 ++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 1364 insertions(+), 1364 deletions(-)


---
~Randy
*** Remember to use Documentation/SubmitChecklist when testing your code ***

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
