Date: Tue, 26 Jun 2001 08:42:05 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: [RFC] VM statistics to gather
Message-ID: <20010626084205.Q18856@redhat.com>
References: <200106252339.f5PNd9x07535@maile.telia.com> <Pine.LNX.4.33L.0106252048230.23373-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33L.0106252048230.23373-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Mon, Jun 25, 2001 at 08:59:11PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Roger Larsson <roger.larsson@norran.net>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Jun 25, 2001 at 08:59:11PM -0300, Rik van Riel wrote:

> > Should memory zone be used as dimension?
> 
> Useful for allocations I guess, but it may be too confusing
> if we do this for all statistics... OTOH...

Then user space monitor apps can summarise over all zones.

Rik, having this information available per-zone is critically
important for doing VM tuning.  Whenever we see VM lockups, being able
to deduce when we're spinning on a single zone will be enormously
helpful.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
