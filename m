Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f175.google.com (mail-ig0-f175.google.com [209.85.213.175])
	by kanga.kvack.org (Postfix) with ESMTP id 30A9A6B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 08:41:04 -0500 (EST)
Received: by mail-ig0-f175.google.com with SMTP id r2so3366504igi.2
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 05:41:03 -0800 (PST)
Received: from mail-ie0-x230.google.com (mail-ie0-x230.google.com. [2607:f8b0:4001:c03::230])
        by mx.google.com with ESMTPS id ac4si1299757igd.20.2015.01.16.05.41.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 16 Jan 2015 05:41:02 -0800 (PST)
Received: by mail-ie0-f176.google.com with SMTP id tr6so20690593ieb.7
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 05:41:01 -0800 (PST)
Message-ID: <1421415659.11734.131.camel@edumazet-glaptop2.roam.corp.google.com>
Subject: Re: [PATCH v2 1/2] mm/slub: optimize alloc/free fastpath by
 removing preemption on/off
From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 16 Jan 2015 05:40:59 -0800
In-Reply-To: <20150115230749.5d73ad49@grimm.local.home>
References: <1421307633-24045-1-git-send-email-iamjoonsoo.kim@lge.com>
	 <20150115171634.685237a4.akpm@linux-foundation.org>
	 <20150115203045.00e9fb73@grimm.local.home>
	 <alpine.DEB.2.11.1501152126300.13976@gentwo.org>
	 <20150115225130.00c0c99a@grimm.local.home>
	 <alpine.DEB.2.11.1501152155480.14236@gentwo.org>
	 <20150115230749.5d73ad49@grimm.local.home>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>

On Thu, 2015-01-15 at 23:07 -0500, Steven Rostedt wrote:
> On Thu, 15 Jan 2015 21:57:58 -0600 (CST)
> Christoph Lameter <cl@linux.com> wrote:
> 
> > > I get:
> > >
> > > 		mov    %gs:0x18(%rax),%rdx
> > >
> > > Looks to me that %gs is used.
> > 
> > %gs is used as a segment prefix. That does not add significant cycles.
> > Retrieving the content of %gs and loading it into another register
> > would be expensive in terms of cpu cycles.
> 
> OK, maybe that's what I saw in my previous benchmarks. Again, that was
> a while ago.

I made same observation about 3 years ago, on old cpus.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
