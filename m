Date: Sat, 10 Feb 2001 20:33:29 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH] 2.4.0-ac8/9  page_launder() fix
In-Reply-To: <Pine.LNX.4.21.0102102051450.2378-100000@duckman.distro.conectiva>
Message-ID: <Pine.LNX.4.21.0102102027250.27734-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>, Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

I just tested it here and it seems to behave pretty well. 

On Sat, 10 Feb 2001, Rik van Riel wrote:

> Hi,
> 
> the patch below should make page_launder() more well-behaved
> than it is in -ac8 and -ac9 ... note, however, that this thing
> is still completely untested and only in theory makes page_launder
> behave better ;)
> 
> Since there seems to be a lot of VM testing going on at the
> moment I thought I might as well send it out now so I can get
> some feedback before I get into the airplane towards sweden
> tomorrow...
> 
> cheers,
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
