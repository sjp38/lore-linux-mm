Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f179.google.com (mail-ie0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2D7356B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 11:37:43 -0500 (EST)
Received: by mail-ie0-f179.google.com with SMTP id rp18so21540620iec.10
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 08:37:43 -0800 (PST)
Received: from smtprelay.hostedemail.com (smtprelay0063.hostedemail.com. [216.40.44.63])
        by mx.google.com with ESMTP id hh11si6852424icb.99.2015.01.16.08.37.41
        for <linux-mm@kvack.org>;
        Fri, 16 Jan 2015 08:37:42 -0800 (PST)
Date: Fri, 16 Jan 2015 11:37:36 -0500
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v2 1/2] mm/slub: optimize alloc/free fastpath by
 removing preemption on/off
Message-ID: <20150116113736.59406ea8@gandalf.local.home>
In-Reply-To: <1421415659.11734.131.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1421307633-24045-1-git-send-email-iamjoonsoo.kim@lge.com>
	<20150115171634.685237a4.akpm@linux-foundation.org>
	<20150115203045.00e9fb73@grimm.local.home>
	<alpine.DEB.2.11.1501152126300.13976@gentwo.org>
	<20150115225130.00c0c99a@grimm.local.home>
	<alpine.DEB.2.11.1501152155480.14236@gentwo.org>
	<20150115230749.5d73ad49@grimm.local.home>
	<1421415659.11734.131.camel@edumazet-glaptop2.roam.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>

On Fri, 16 Jan 2015 05:40:59 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> I made same observation about 3 years ago, on old cpus.
> 

Thank you for letting me know. I was thinking I was going insane!

(yeah yeah, there's lots of people who will still say that I've already
gone insane, but at least I know my memory is still intact)

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
