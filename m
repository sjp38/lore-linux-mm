Date: Thu, 16 Nov 2000 14:05:37 -0200 (BRDT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: KPATCH] Reserve VM for root (was: Re: Looking for better VM)
In-Reply-To: <20001116170354.A9501@caldera.de>
Message-ID: <Pine.LNX.4.21.0011161404540.13085-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@ns.caldera.de>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 16 Nov 2000, Christoph Hellwig wrote:
> On Thu, Nov 16, 2000 at 01:51:01PM -0200, Rik van Riel wrote:
> > > If you think fork() kills the box then ulimit the maximum number
> > > of user processes (ulimit -u). This is a different issue and a
> > > bad design in the scheduler (see e.g. Tru64 for a better one).
> > 
> > My fair scheduler catches this one just fine. It hasn't
> > been integrated in the kernel yet, but both VA Linux and
> > Conectiva use it in their kernel RPM.
> 
> BTW: do you have a fairsched patch for 2.4?

I haven't updated it yet to the latest kernels yet...

[but I, or someone else, should ;)]

regards,

Rik
--
"What you're running that piece of shit Gnome?!?!"
       -- Miguel de Icaza, UKUUG 2000

http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
