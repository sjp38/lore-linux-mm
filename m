Date: Sun, 29 Apr 2001 15:17:11 +0200
From: Andrea Arcangeli <andrea@suse.de>
Subject: Re: RFC: Bouncebuffer fixes
Message-ID: <20010429151711.A11395@athlon.random>
References: <20010428170648.A10582@devserv.devel.redhat.com> <20010429020757.C816@athlon.random> <20010429035626.B14210@devserv.devel.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20010429035626.B14210@devserv.devel.redhat.com>; from arjanv@redhat.com on Sun, Apr 29, 2001 at 03:56:26AM -0400
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjanv@redhat.com>
Cc: linux-mm@kvack.org, alan@lxorguk.ukuu.org.uk, Linus Torvalds <torvalds@transmeta.com>
List-ID: <linux-mm.kvack.org>

On Sun, Apr 29, 2001 at 03:56:26AM -0400, Arjan van de Ven wrote:
> This looks like the code in Alan's tree around 2.4.3-ac7, and that is NOT 
> enough to fix the deadlock. With that patch, tests deadlock within 10 minutes....
> 
> One of the reasons it deadlocks is because GFP_BUFFER can sleep here,
> without the guarantee of progress. The regular VM threads that should

GFP_BUFFER doesn't provide guarantee of progress and that's fine, as far
as GFP_BUFFER allocations returns NULL eventually there should be no
problem. The fact some emergency buffer is in flight is just the guarantee
of progress because after unplugging tq_disk we know those emergency
buffers will be released without the need of further memory allocations.

If GFP_BUFFER allocation never returns and they deadlocks inside the VM
that's a completly unrelated bug and I think you shouldn't workaround it
in highmem.c.

Andrea
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
