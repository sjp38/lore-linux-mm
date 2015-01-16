Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 8088D6B0032
	for <linux-mm@kvack.org>; Thu, 15 Jan 2015 23:03:48 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id y13so20282410pdi.2
        for <linux-mm@kvack.org>; Thu, 15 Jan 2015 20:03:48 -0800 (PST)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.231])
        by mx.google.com with ESMTP id ho8si3933707pbc.204.2015.01.15.20.03.45
        for <linux-mm@kvack.org>;
        Thu, 15 Jan 2015 20:03:46 -0800 (PST)
Date: Thu, 15 Jan 2015 23:04:09 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v2 1/2] mm/slub: optimize alloc/free fastpath by
 removing preemption on/off
Message-ID: <20150115230409.2b37c071@grimm.local.home>
In-Reply-To: <20150115225130.00c0c99a@grimm.local.home>
References: <1421307633-24045-1-git-send-email-iamjoonsoo.kim@lge.com>
	<20150115171634.685237a4.akpm@linux-foundation.org>
	<20150115203045.00e9fb73@grimm.local.home>
	<alpine.DEB.2.11.1501152126300.13976@gentwo.org>
	<20150115225130.00c0c99a@grimm.local.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>

On Thu, 15 Jan 2015 22:51:30 -0500
Steven Rostedt <rostedt@goodmis.org> wrote:

> 
> I haven't done benchmarks in a while, so perhaps accessing the %gs
> segment isn't as expensive as I saw it before. I'll have to profile
> function tracing on my i7 and see where things are slow again.

I just ran it on my i7, and yeah, the %gs access isn't much worse than
any of the other instructions. I had an old box that recently died that
I did my last benchmarks on, so that was probably why it made such a
difference.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
