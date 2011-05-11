Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id CFA43900001
	for <linux-mm@kvack.org>; Wed, 11 May 2011 16:03:28 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id p4BK3RAf008794
	for <linux-mm@kvack.org>; Wed, 11 May 2011 13:03:27 -0700
Received: from pwi12 (pwi12.prod.google.com [10.241.219.12])
	by kpbe12.cbf.corp.google.com with ESMTP id p4BK3FPs015270
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 11 May 2011 13:03:26 -0700
Received: by pwi12 with SMTP id 12so425318pwi.28
        for <linux-mm@kvack.org>; Wed, 11 May 2011 13:03:26 -0700 (PDT)
Date: Wed, 11 May 2011 13:03:24 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [Slub cleanup6 3/5] slub: Eliminate repeated use of c->page
 through a new page variable
In-Reply-To: <20110415194831.409760374@linux.com>
Message-ID: <alpine.DEB.2.00.1105111255000.9346@chino.kir.corp.google.com>
References: <20110415194811.810587216@linux.com> <20110415194831.409760374@linux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org

On Fri, 15 Apr 2011, Christoph Lameter wrote:

> __slab_alloc is full of "c->page" repeats. Lets just use one local variable
> named "page" for this. Also avoids the need to a have another variable
> called "new".
> 
> Signed-off-by: Christoph Lameter <cl@linux.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
