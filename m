Date: Wed, 19 Jun 2002 13:24:55 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [PATCH] (1/2) reverse mapping VM for 2.5.23 (rmap-13b)
In-Reply-To: <Pine.LNX.4.44.0206191310590.4292-100000@loke.as.arizona.edu>
Message-ID: <Pine.LNX.4.33.0206191322480.2638-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Craig Kulesa <ckulesa@as.arizona.edu>
Cc: Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@conectiva.com.br>, Dave Jones <davej@suse.de>, Daniel Phillips <phillips@bonn-fries.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rwhron@earthlink.net
List-ID: <linux-mm.kvack.org>

On Wed, 19 Jun 2002, Craig Kulesa wrote:
> 
> I'll try a more varied set of tests tonight, with cpu usage tabulated.

Please do a few non-swap tests too. 

Swapping is the thing that rmap is supposed to _help_, so improvements in
that area are good (and had better happen!), but if you're only looking at
the swap performance, you're ignoring the known problems with rmap, ie the
cases where non-rmap kernels do really well.

Comparing one but not the other doesn't give a very balanced picture..

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
