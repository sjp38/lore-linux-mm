Subject: Re: Hopefully a simple question on /proc/pid/mem
References: <Pine.GSO.4.21.0104301457010.5737-100000@weyl.math.psu.edu> <Pine.LNX.3.96.1010430145934.30664D-100000@kanga.kvack.org> <20010430225802.H26638@redhat.com>
From: ebiederm@xmission.com (Eric W. Biederman)
Date: 30 Apr 2001 19:13:53 -0600
In-Reply-To: "Stephen C. Tweedie"'s message of "Mon, 30 Apr 2001 22:58:02 +0100"
Message-ID: <m166flhnvy.fsf@frodo.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: "Benjamin C.R. LaHaise" <blah@kvack.org>, Alexander Viro <viro@math.psu.edu>, Richard F Weber <rfweber@link.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" <sct@redhat.com> writes:

> Hi,
> 
> On Mon, Apr 30, 2001 at 03:02:40PM -0400, Benjamin C.R. LaHaise wrote:
> > On Mon, 30 Apr 2001, Alexander Viro wrote:
> > 
> > > I wonder what's wrong with reading from /proc/<pid>/mem, though - it's
> > > using the same code as ptrace.
> > 
> > We can actually do this cleanly now that we have proper page_dirty
> > semantics for raw io.  The original reason for disabling /proc/*/mem was
> > that it left big gaping holes in the mm code in 2.0, and it hasn't been
> > repaired since.
> 
> It was mmap of /proc/*/mem which was busted.  read/write should be OK.
> 
> Hint: think about what happens if you make a shared mapping of a
> private proc/*/mem region... 

Now that we have reusable swap cache pages we could make it work
correctly, except for the case of the first write a private mapping of
file.    Not that we would want to...

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
