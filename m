Date: Sat, 14 Sep 2002 01:01:13 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: 2.5.34-mm4
In-Reply-To: <3D82B5C3.229C6B1A@digeo.com>
Message-ID: <Pine.LNX.4.44L.0209140059460.1857-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lse-tech@lists.sourceforge.net" <lse-tech@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

On Fri, 13 Sep 2002, Andrew Morton wrote:

> +iowait.patch
>
>  Instrumentation to show how much time is spent in disk wait.  (Doesn't
>  appear to come out in the new top(1) though?)

Will add it now that you're shipping it again.  Note that this
will be available as patches on my home page and from my bk
tree only for now.  I'll merge the needed patches into the main
procps tree once this stuff gets merged into the kernel.

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

Spamtraps of the month:  september@surriel.com trac@trac.org

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
