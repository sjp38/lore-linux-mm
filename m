Date: Mon, 23 Oct 2000 20:38:53 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Another wish item for your TODO list...
Message-ID: <20001023203853.A3295@redhat.com>
References: <20001023183649.H2772@redhat.com> <Pine.LNX.4.21.0010231559230.13115-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.21.0010231559230.13115-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Mon, Oct 23, 2000 at 04:07:02PM -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Oct 23, 2000 at 04:07:02PM -0200, Rik van Riel wrote:

> > It's an optimisation in CPU time as much as for anything else:
> > there's just no point in doing expensive memory balancing/aging
> > for pages which we know are next to useless.
> 
> The problem here is that we shouldn't remove the pages which are
> in the current readahead window, as those /will/ most likely be
> used in the near future.

It probably only makes real sense to do this for inodes which are not
in use, anyway, which avoids that problem completely.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
