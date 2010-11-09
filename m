Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id DFD386B0071
	for <linux-mm@kvack.org>; Tue,  9 Nov 2010 15:20:56 -0500 (EST)
Date: Tue, 9 Nov 2010 15:20:33 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: 2.6.36 io bring the system to its knees
Message-ID: <20101109202033.GA17122@infradead.org>
References: <AANLkTikvSGNE7uGn5p0tfJNg4Hz5WRmLRC8cXu7+GhMk@mail.gmail.com>
 <20101028090002.GA12446@elte.hu>
 <AANLkTinoGGLTN2JRwjJtF6Ra5auZVg+VSa=TyrtAkDor@mail.gmail.com>
 <20101028133036.GA30565@elte.hu>
 <20101028170132.GY27796@think>
 <alpine.LNX.2.00.1011050032440.16015@swampdragon.chaosbits.net>
 <alpine.LNX.2.00.1011050047220.16015@swampdragon.chaosbits.net>
 <20101105014334.GF13830@dastard>
 <alpine.LNX.2.00.1011071753560.26056@swampdragon.chaosbits.net>
 <AANLkTinZCBs_JO0Ug58uJdWEuqx=xzzBn2nJzdYr7+hb@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTinZCBs_JO0Ug58uJdWEuqx=xzzBn2nJzdYr7+hb@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Evgeniy Ivanov <lolkaantimat@gmail.com>
Cc: Jesper Juhl <jj@chaosbits.net>, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Ingo Molnar <mingo@elte.hu>, Pekka Enberg <penberg@kernel.org>, Aidar Kultayev <the.aidar@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Ted Ts'o <tytso@mit.edu>, Corrado Zoccolo <czoccolo@gmail.com>, Shaohua Li <shaohua.li@intel.com>, Sanjoy Mahajan <sanjoy@olin.edu>, Steven Barrett <damentz@gmail.com>
List-ID: <linux-mm.kvack.org>

> I'm not sure if "data=writeback" (makes ext4 journaling similar to
> XFS) really fixes the problem

It doesn't.  XFS does not expose stale data after a crash, while ext3/4
data=writeback does.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
