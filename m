Date: Fri, 23 Jun 2000 00:59:45 +0100
From: Stephen Tweedie <sct@redhat.com>
Subject: Re: [RFC] RSS guarantees and limits
Message-ID: <20000623005945.E9244@redhat.com>
References: <Pine.LNX.4.21.0006221834530.1137-100000@duckman.distro.conectiva> <m2itv19vt9.fsf@boreas.southchinaseas>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <m2itv19vt9.fsf@boreas.southchinaseas>; from vii@penguinpowered.com on Thu, Jun 22, 2000 at 11:48:18PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: John Fremlin <vii@penguinpowered.com>
Cc: Rik van Riel <riel@conectiva.com.br>, Stephen Tweedie <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Thu, Jun 22, 2000 at 11:48:18PM +0100, John Fremlin wrote:
> 
> I booted up with mem=8M today, and found that even small things like
> bash were about 20% of system ram. By not letting a single big process
> (about the biggest that'd fit was emacs) get most all of the memory
> from the various junk that wasn't being used, the system would be
> completely unusable rather than merely a little slow.

The RSS bounds are *DYNAMIC*.  If there is contention for memory ---
if lots of other processes want the memory that that emacs is 
holding --- then absolutely you want to cut back on the emacs RSS.
If there is no competition, and emacs is the only active process, then
there is no need to prune its RSS.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
