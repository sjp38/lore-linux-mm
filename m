Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id B19DD6B004D
	for <linux-mm@kvack.org>; Fri, 16 Oct 2009 10:55:29 -0400 (EDT)
Date: Fri, 16 Oct 2009 09:55:26 -0500
From: Robin Holt <holt@sgi.com>
Subject: Re: [patch 0/2] x86, UV: fixups for configurations with a large
	number of nodes.
Message-ID: <20091016145526.GA8903@sgi.com>
References: <20091015223959.783988000@alcatraz.americas.sgi.com> <20091016063405.GB20388@elte.hu> <20091016112920.GZ8903@sgi.com> <20091016125313.GB15393@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091016125313.GB15393@elte.hu>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>
Cc: Robin Holt <holt@sgi.com>, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jack Steiner <steiner@sgi.com>, Cliff Whickman <cpw@sgi.com>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 16, 2009 at 02:53:13PM +0200, Ingo Molnar wrote:
...
> So ... is the commit log message i've put into the commit below correct, 
> or is it still only a cleanup patch? You really need to put that kind of 
> info into your changelogs - it helps maintainers put it into the right 
> kernel release.
> 
> 	Ingo

...

> The open-coded code was wrong as well - it might explain a
> few of our unexplained bau hangs.

Terrific.  Thank you for fixing up my commit message.  I will try to be
more complete next time.

Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
