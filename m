Date: Wed, 4 Jul 2001 03:29:05 -0300 (BRT)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: [PATCH] initial detailed VM statistics code
In-Reply-To: <3B42CAA7.507F599F@earthlink.net>
Message-ID: <Pine.LNX.4.21.0107040326060.3418-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Joseph A. Knapka" <jknapka@earthlink.net>
Cc: linux-mm@kvack.org, Rik van Riel <riel@conectiva.com.br>
List-ID: <linux-mm.kvack.org>


On Wed, 4 Jul 2001, Joseph A. Knapka wrote:

> Marcelo Tosatti wrote:
> > 
> > Hi,
> > 
> > Well, I've started working on VM stats code for 2.4.
> > 
> 
> Thanks.
> 
> It might be useful to have a count of the number of PTEs scanned
> by swap_out(), and the number of those that were unmapped. (I'm
> interested in the scan rate of swap_out() vs refill_inactive_scan()).

Hum, 

The number of pages with age 0 which have mapped PTEs (thus cannot be
freed) is what you're looking for ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
