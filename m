Date: Mon, 21 May 2001 14:36:04 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [RFC][PATCH] Re: Linux 2.4.4-ac10
Message-ID: <20010521143604.C8080@redhat.com>
References: <Pine.LNX.4.33.0105201104090.610-100000@mikeg.weiden.de> <Pine.LNX.4.21.0105200703270.5531-100000@imladris.rielhome.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0105200703270.5531-100000@imladris.rielhome.conectiva>; from riel@conectiva.com.br on Sun, May 20, 2001 at 07:04:31AM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Mike Galbraith <mikeg@wen-online.de>, "Stephen C. Tweedie" <sct@redhat.com>, Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Sun, May 20, 2001 at 07:04:31AM -0300, Rik van Riel wrote:
> On Sun, 20 May 2001, Mike Galbraith wrote:
> > 
> > Looking at the locking and trying to think SMP (grunt) though, I
> > don't like the thought of taking two locks for each page until
> 
> > 100%.  The data in that block is toast anyway.  A big hairy SMP
> > box has to feel reclaim_page(). (they probably feel the zone lock
> > too.. probably would like to allocate blocks)
> 
> Indeed, but this is a separate problem.  Doing per-CPU private
> (small, 8-32 page?) free lists is probably a good idea

Ingo already implemented that for Tux2.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
