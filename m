Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 59BF46B0087
	for <linux-mm@kvack.org>; Mon,  6 Dec 2010 10:54:14 -0500 (EST)
Date: Mon, 6 Dec 2010 09:54:04 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [thisops uV3 14/18] lguest: Use this_cpu_ops
In-Reply-To: <201012061816.07860.rusty@rustcorp.com.au>
Message-ID: <alpine.DEB.2.00.1012060952540.32000@router.home>
References: <20101130190707.457099608@linux.com> <20101130190849.422541374@linux.com> <201012061816.07860.rusty@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Rusty Russell <rusty@rustcorp.com.au>
Cc: akpm@linux-foundation.org, Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 6 Dec 2010, Rusty Russell wrote:

> This doesn't even compile :(

Yeah. I had to go through a lot of code and the build process did not
build all subsystem. Sorry.

> I've applied it, and applied the following fixes, too:

Great. Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
