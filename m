Date: Mon, 9 Oct 2000 20:29:00 +0200
From: Jamie Lokier <lk@tantalophile.demon.co.uk>
Subject: Re: [PATCH] VM fix for 2.4.0-test9 & OOM handler
Message-ID: <20001009202900.A3821@pcep-jamie.cern.ch>
References: <Pine.LNX.4.21.0010061721520.13585-100000@duckman.distro.conectiva> <Pine.LNX.4.21.0010091159430.20087-100000@Megathlon.ESI> <20001009182651.S1679@garloff.etpnet.phys.tue.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20001009182651.S1679@garloff.etpnet.phys.tue.nl>; from garloff@suse.de on Mon, Oct 09, 2000 at 06:26:51PM +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kurt Garloff <garloff@suse.de>, Marco Colombo <marco@esi.it>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Kurt Garloff wrote:
> I could not agree more. Normally, you'd better kill a foreground task
> (running nice 0) than selecting one of those background jobs for some
> reasons:
> * The foreground job can be restarted by the interactive user
>   (Most likely, it will be only netscape anyway)
> * The background job probably is the more useful one which has been running
>   since a longer time (computations, ...)

Ick.  A background job that's been running for a long time will be saved
by that, as Rik pointed out.

If I've got a background process running for 30 minutes, and a Netscape
with 5 windows open that I'm using (for long or not, doesn't matter),
guess which one I'd rather died?  Not Netscape -- I'm using that and
I'll never remember how to find those 5 windows again if it just dies.

-- Jamie
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
