Date: Thu, 19 Apr 2001 11:14:57 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
Message-ID: <20010419111457.C28865@redhat.com>
References: <Pine.LNX.4.30.0104190031190.20939-100000@fs131-224.f-secure.com> <Pine.LNX.4.33.0104181918290.17635-100000@duckman.distro.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.33.0104181918290.17635-100000@duckman.distro.conectiva>; from riel@conectiva.com.br on Wed, Apr 18, 2001 at 07:29:26PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: Szabolcs Szakacsits <szaka@f-secure.com>, "James A. Sutherland" <jas88@cam.ac.uk>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

On Wed, Apr 18, 2001 at 07:29:26PM -0300, Rik van Riel wrote:
> On Thu, 19 Apr 2001, Szabolcs Szakacsits wrote:
> 
> > This is not true. There *is* progress, it just can be painful slow.
> 
> "Painfully slow" when you are thrashing  ==  "root cannot login
> because his login times out every time he tries to login".

Not necessarily.  If we can guarantee a minimal working set size to
all active processes when under severe VM load, then processes like
login may still be slow but they will at least be able to make
progress.  The existance of thrashing will obviously have an impact on
the swap device performance for all processes, but the thrashing's
impact on other processes' working sets can, and should, be
controlled.

> THIS is why we need process suspension in the kernel.

Not necessarily.  Creating a minimal working set guarantee for small
tasks is one way to avoid the need for process suspension.  Creating a
dynamic working set upper limit for large, thrashing tasks is a way to
avoid the thrashing tasks from impacting everybody else too much.
There are many possible ways forward, and I am not yet convinced that
process suspension is necessary.

Cheers,
 Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
