Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 937378D005B
	for <linux-mm@kvack.org>; Sat, 30 Oct 2010 15:08:34 -0400 (EDT)
Date: Sat, 30 Oct 2010 15:06:07 -0400
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: 2.6.36 io bring the system to its knees
Message-ID: <20101030190607.GB2918@think>
References: <AANLkTikvSGNE7uGn5p0tfJNg4Hz5WRmLRC8cXu7+GhMk@mail.gmail.com>
 <20101028090002.GA12446@elte.hu>
 <AANLkTinoGGLTN2JRwjJtF6Ra5auZVg+VSa=TyrtAkDor@mail.gmail.com>
 <20101028133036.GA30565@elte.hu>
 <20101028170132.GY27796@think>
 <AANLkTikgO=n88ZAQ6EYAg1+aC1d0+o923FYyhkOouaH5@mail.gmail.com>
 <20101029145212.GA21205@thunk.org>
 <AANLkTim-A7DLOOw4myQU3Lfip+ZEE32F2Ap_PJXuxG6G@mail.gmail.com>
 <20101030091440.GA15276@elte.hu>
 <AANLkTim-hgA3-9T_N5k53Sga5LMazMQPmmQZzQsoQvRY@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTim-hgA3-9T_N5k53Sga5LMazMQPmmQZzQsoQvRY@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Aidar Kultayev <the.aidar@gmail.com>
Cc: Ingo Molnar <mingo@elte.hu>, Ted Ts'o <tytso@mit.edu>, Pekka Enberg <penberg@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>

On Sat, Oct 30, 2010 at 07:02:35PM +0600, Aidar Kultayev wrote:
> Hi,
> 
> here is what I have :
> 
> .ext4 mounted with data=ordered
> .-tip tree ( uname -a gives : Linux pussy 2.6.36-tip+ )
> 
> here is the latencytop & powertop & top screenshot:
> 
> http://picasaweb.google.com/lh/photo/bMTgbVDoojwUeXtVdyvIKw?feat=directlink

It's actually better, fsync is missing anyway.  Please try ext4
data=writeback.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
