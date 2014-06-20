Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id 81CF56B0036
	for <linux-mm@kvack.org>; Fri, 20 Jun 2014 10:30:59 -0400 (EDT)
Received: by mail-qa0-f49.google.com with SMTP id w8so3203941qac.22
        for <linux-mm@kvack.org>; Fri, 20 Jun 2014 07:30:59 -0700 (PDT)
Received: from qmta10.emeryville.ca.mail.comcast.net (qmta10.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:17])
        by mx.google.com with ESMTP id l66si10795242qgf.78.2014.06.20.07.30.58
        for <linux-mm@kvack.org>;
        Fri, 20 Jun 2014 07:30:58 -0700 (PDT)
Date: Fri, 20 Jun 2014 09:30:52 -0500 (CDT)
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: slub/debugobjects: lockup when freeing memory
In-Reply-To: <20140619220449.GT4904@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.11.1406200930270.10271@gentwo.org>
References: <53A2F406.4010109@oracle.com> <alpine.DEB.2.11.1406191001090.2785@gentwo.org> <20140619165247.GA4904@linux.vnet.ibm.com> <alpine.DEB.2.10.1406192127100.5170@nanos> <20140619202928.GG4904@linux.vnet.ibm.com> <alpine.DEB.2.10.1406192230390.5170@nanos>
 <20140619205307.GL4904@linux.vnet.ibm.com> <alpine.DEB.2.10.1406192331250.5170@nanos> <20140619220449.GT4904@linux.vnet.ibm.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Sasha Levin <sasha.levin@oracle.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, 19 Jun 2014, Paul E. McKenney wrote:

> This commit therefore exports the debug_init_rcu_head() and
> debug_rcu_head_free() functions, which permits the allocators to allocated
> and pre-initialize the debug-objects information, so that there no longer
> any need for call_rcu() to do that initialization, which in turn prevents
> the recursion into the memory allocators.

Looks-good-to: Christoph Lameter <cl@linux.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
