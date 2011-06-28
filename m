Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D55ED6B00F1
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 16:58:19 -0400 (EDT)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id p5SKwFRA015544
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 13:58:15 -0700
Received: from pzk37 (pzk37.prod.google.com [10.243.19.165])
	by kpbe20.cbf.corp.google.com with ESMTP id p5SKw8rD017039
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 28 Jun 2011 13:58:13 -0700
Received: by pzk37 with SMTP id 37so468468pzk.29
        for <linux-mm@kvack.org>; Tue, 28 Jun 2011 13:58:08 -0700 (PDT)
Date: Tue, 28 Jun 2011 13:58:06 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slub: reduce overhead of slub_debug
In-Reply-To: <4E0A2E26.5000001@gmail.com>
Message-ID: <alpine.DEB.2.00.1106281355010.4229@chino.kir.corp.google.com>
References: <20110626193918.GA3339@joi.lan> <alpine.DEB.2.00.1106281431370.27518@router.home> <4E0A2E26.5000001@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Daney <ddaney.cavm@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Marcin Slusarz <marcin.slusarz@gmail.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Tue, 28 Jun 2011, David Daney wrote:

> On 06/28/2011 12:32 PM, Christoph Lameter wrote:
> > On Sun, 26 Jun 2011, Marcin Slusarz wrote:
> > 
> > > slub checks for poison one byte by one, which is highly inefficient
> > > and shows up frequently as a highest cpu-eater in perf top.
> > 
> > Ummm.. Performance improvements for debugging modes? If you need
> > performance then switch off debuggin.
> 
> There is no reason to make things gratuitously slow.  I don't know about the
> merits of this particular patch, but I must disagree with the general
> sentiment.
> 
> We have high performance tracing, why not improve this as well.
> 
> Just last week I was trying to find the cause of memory corruption that only
> occurred at very high network packet rates.  Memory allocation speed was
> definitely getting in the way of debugging.  For me, faster SLUB debugging
> would be welcome.
> 

SLUB debugging is useful only to diagnose issues or test new code, nobody 
is going to be enabling it in production environment.  We don't need 30 
new lines of code that make one thing slightly faster, in fact we'd prefer 
to have as simple and minimal code as possible for debugging features 
unless you're adding more debugging coverage.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
