Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id C216A483D9
	for <linux-mm@kvack.org>; Wed,  4 Dec 2002 10:12:35 -0200 (BRST)
Date: Wed, 4 Dec 2002 10:12:23 -0200 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: [PATCH] 2.4.20-rmap15a
In-Reply-To: <1039002006.1879.0.camel@laptop.fenrus.com>
Message-ID: <Pine.LNX.4.50L.0212041012150.22252-100000@duckman.distro.conectiva>
References: <Pine.LNX.4.44L.0212011833310.15981-100000@imladris.surriel.com>
 <6usmxfys45.fsf@zork.zork.net> <20021203195854.GA6709@zork.net>
 <30200000.1038946087@titus>  <Pine.LNX.4.50L.0212031855590.22252-100000@duckman.distro.conectiva>
 <1039002006.1879.0.camel@laptop.fenrus.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjanv@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 4 Dec 2002, Arjan van de Ven wrote:
> On Tue, 2002-12-03 at 21:56, Rik van Riel wrote:
> > On Tue, 3 Dec 2002, Martin J. Bligh wrote:
> >
> > > Assuming the extra time is eaten in Sys, not User,
> >
> > It's not. It's idle time.  Looks like something very strange
> > is going on, vmstat and top output would be nice to have...
>
> I wonder if we miss a run of the tq_disk somewhere.....

The most likely cause, indeed.

Rik
-- 
A: No.
Q: Should I include quotations after my reply?

http://www.surriel.com/		http://distro.conectiva.com/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
