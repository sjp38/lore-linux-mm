Date: Sat, 24 Mar 2001 09:04:19 +0100 (CET)
From: Mike Galbraith <mikeg@wen-online.de>
Subject: Re: [PATCH] Prevent OOM from killing init
In-Reply-To: <Pine.LNX.4.21.0103240255090.1863-100000@imladris.rielhome.conectiva>
Message-ID: <Pine.LNX.4.33.0103240852360.2137-100000@mikeg.weiden.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sat, 24 Mar 2001, Rik van Riel wrote:

> On Fri, 23 Mar 2001, george anzinger wrote:
>
> > What happens if you just make swap VERY large?  Does the system thrash
> > it self to a virtual standstill?
>
> It does.  I need to implement load control code (so we suspend
> processes in turn to keep the load low enough so we can avoid
> thrashing).

That would be a nice emergency feature.  I've run into the situation
where the box was thrashing so badly that it was impossible to login
to try to regain control.  Getting a login prompt took nearly forever,
and I could'nt get a passwd entered before login timed-out :)

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
