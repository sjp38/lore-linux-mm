Date: Fri, 27 Dec 2002 14:16:34 -0600
From: Dave McCracken <dmc@austin.ibm.com>
Subject: Re: shared pagetable benchmarking
Message-ID: <47580000.1041020194@[10.1.1.5]>
In-Reply-To: <Pine.LNX.4.44.0212271201130.21930-100000@home.transmeta.com>
References: <Pine.LNX.4.44.0212271201130.21930-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Daniel Phillips <phillips@arcor.de>, Andrew Morton <akpm@digeo.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--On Friday, December 27, 2002 12:02:56 -0800 Linus Torvalds
<torvalds@transmeta.com> wrote:

> It doesn't break even on small forks. It _slows_them_down_.

I gave Andrew a patch that does make it break even on small forks, by doing
the copy at fork time when a process only has 3 pte pages.  My tests
indicate that any process with 4 or more pte pages usually is faster by
doing the share.

Dave McCracken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
