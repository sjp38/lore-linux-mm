Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 1F2956B01AC
	for <linux-mm@kvack.org>; Fri, 18 Jun 2010 13:32:28 -0400 (EDT)
Date: Fri, 18 Jun 2010 12:29:02 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 1/2] percpu: make @dyn_size always mean min dyn_size in
 first chunk init functions
In-Reply-To: <4C1BA59C.6000309@kernel.org>
Message-ID: <alpine.DEB.2.00.1006181225370.13915@router.home>
References: <alpine.DEB.2.00.1006151406120.10865@router.home> <alpine.DEB.2.00.1006151409240.10865@router.home> <4C189119.5050801@kernel.org> <alpine.DEB.2.00.1006161131520.4554@router.home> <4C190748.7030400@kernel.org> <alpine.DEB.2.00.1006161231420.6361@router.home>
 <4C19E19D.2020802@kernel.org> <alpine.DEB.2.00.1006170842410.22997@router.home> <4C1BA59C.6000309@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Tejun Heo <tj@kernel.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ok this worked when testing on x86 32 bit SMP no NUMA (after removal of
the bootstrap percpu areas in slub). The same config fails without
the patches (x86 64 bit NUMA works fine).

So if this is merged then we can drop the static percpu allocation and the
special boot handling.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
