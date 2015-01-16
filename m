Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 5DF6C6B0038
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 23:07:27 -0500 (EST)
Received: by mail-pa0-f42.google.com with SMTP id et14so21779664pad.1
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 20:07:27 -0800 (PST)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.229])
        by mx.google.com with ESMTP id c4si4087434pas.96.2015.01.15.20.07.25
        for <linux-mm@kvack.org>;
        Thu, 15 Jan 2015 20:07:26 -0800 (PST)
Date: Thu, 15 Jan 2015 23:07:49 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v2 1/2] mm/slub: optimize alloc/free fastpath by
 removing preemption on/off
Message-ID: <20150115230749.5d73ad49@grimm.local.home>
In-Reply-To: <alpine.DEB.2.11.1501152155480.14236@gentwo.org>
References: <1421307633-24045-1-git-send-email-iamjoonsoo.kim@lge.com>
	<20150115171634.685237a4.akpm@linux-foundation.org>
	<20150115203045.00e9fb73@grimm.local.home>
	<alpine.DEB.2.11.1501152126300.13976@gentwo.org>
	<20150115225130.00c0c99a@grimm.local.home>
	<alpine.DEB.2.11.1501152155480.14236@gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>

On Thu, 15 Jan 2015 21:57:58 -0600 (CST)
Christoph Lameter <cl@linux.com> wrote:

> > I get:
> >
> > 		mov    %gs:0x18(%rax),%rdx
> >
> > Looks to me that %gs is used.
> 
> %gs is used as a segment prefix. That does not add significant cycles.
> Retrieving the content of %gs and loading it into another register
> would be expensive in terms of cpu cycles.

OK, maybe that's what I saw in my previous benchmarks. Again, that was
a while ago.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
