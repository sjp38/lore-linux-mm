Date: Thu, 16 Nov 2000 17:03:54 +0100
From: Christoph Hellwig <hch@ns.caldera.de>
Subject: Re: KPATCH] Reserve VM for root (was: Re: Looking for better VM)
Message-ID: <20001116170354.A9501@caldera.de>
References: <Pine.LNX.4.30.0011161513480.20626-100000@fs129-190.f-secure.com> <Pine.LNX.4.21.0011161313310.13085-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0011161313310.13085-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Thu, Nov 16, 2000 at 01:51:01PM -0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 16, 2000 at 01:51:01PM -0200, Rik van Riel wrote:
> > If you think fork() kills the box then ulimit the maximum number
> > of user processes (ulimit -u). This is a different issue and a
> > bad design in the scheduler (see e.g. Tru64 for a better one).
> 
> My fair scheduler catches this one just fine. It hasn't
> been integrated in the kernel yet, but both VA Linux and
> Conectiva use it in their kernel RPM.

BTW: do you have a fairsched patch for 2.4?

	Christoph

-- 
Always remember that you are unique.  Just like everyone else.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
