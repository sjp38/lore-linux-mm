Date: Tue, 9 Oct 2001 19:04:49 -0700
Subject: Re: [CFT][PATCH *] faster cache reclaim
Message-ID: <20011009190449.A25261@gnuppy>
References: <Pine.LNX.4.33L.0110082032070.26495-100000@duckman.distro.conectiva> <1002670160.862.15.camel@phantasy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1002670160.862.15.camel@phantasy>
From: Bill Huey <billh@gnuppy.monkey.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robert Love <rml@tech9.net>
Cc: Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org, kernelnewbies@nl.linux.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Oct 09, 2001 at 07:29:13PM -0400, Robert Love wrote:
> For example, starting a `dbench 16' would sometimes cause a brief stall
> (especially if it is the second run of dbench).  It's better now, but
> still not perfect.  The VM holds a lot of locks for a long time.
> 
> Good work.  I hope Alan sees it soon.

Yeah, but overall the performance of his recent patch is pretty amazing.

It's really good that Linux is finally getting a VM that behaves well and
can keep the working set in memory without heavy IO activity flushing out
critical process pages. The performance of Riel's VM system should hold for
server activity too. And adding something like thrash control to help make
sure aging still works (without statistical scattering) under heavy load
should allow Riel's VM to progress under loads that would freeze previous VMs.

;-)

bill

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
