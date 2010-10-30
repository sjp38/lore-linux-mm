Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 458EC6B0157
	for <linux-mm@kvack.org>; Sat, 30 Oct 2010 05:14:57 -0400 (EDT)
Date: Sat, 30 Oct 2010 11:14:40 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: 2.6.36 io bring the system to its knees
Message-ID: <20101030091440.GA15276@elte.hu>
References: <AANLkTinzJ9a+9w7G5X0uZpX2o-L8E6XW98VFKoF1R_-S@mail.gmail.com>
 <AANLkTinDDG0ZkNFJZXuV9k3nJgueUW=ph8AuHgyeAXji@mail.gmail.com>
 <AANLkTikvSGNE7uGn5p0tfJNg4Hz5WRmLRC8cXu7+GhMk@mail.gmail.com>
 <20101028090002.GA12446@elte.hu>
 <AANLkTinoGGLTN2JRwjJtF6Ra5auZVg+VSa=TyrtAkDor@mail.gmail.com>
 <20101028133036.GA30565@elte.hu>
 <20101028170132.GY27796@think>
 <AANLkTikgO=n88ZAQ6EYAg1+aC1d0+o923FYyhkOouaH5@mail.gmail.com>
 <20101029145212.GA21205@thunk.org>
 <AANLkTim-A7DLOOw4myQU3Lfip+ZEE32F2Ap_PJXuxG6G@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTim-A7DLOOw4myQU3Lfip+ZEE32F2Ap_PJXuxG6G@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Aidar Kultayev <the.aidar@gmail.com>
Cc: Ted Ts'o <tytso@mit.edu>, Pekka Enberg <penberg@kernel.org>, Chris Mason <chris.mason@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Nick Piggin <npiggin@suse.de>, Arjan van de Ven <arjan@infradead.org>, Thomas Gleixner <tglx@linutronix.de>
List-ID: <linux-mm.kvack.org>


* Aidar Kultayev <the.aidar@gmail.com> wrote:

> puling the git now - I will try whatever you throw at me.

Ted, i stuck that patch into tip:out-of-tree as:

  22fd555f6c5f: <not for upstream> ext4: Relax i_mutex hold times

So that Aidar can test things more easily via:

  http://people.redhat.com/mingo/tip.git/README

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
