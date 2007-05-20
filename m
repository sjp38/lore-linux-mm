Date: Sun, 20 May 2007 02:15:48 +0200
From: Folkert van Heusden <folkert@vanheusden.com>
Subject: Re: [RFC] log out-of-virtual-memory events
Message-ID: <20070520001548.GK14578@vanheusden.com>
References: <464C81B5.8070101@users.sourceforge.net> <464C9D82.60105@redhat.com> <464D5AA4.8080900@users.sourceforge.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <464D5AA4.8080900@users.sourceforge.net>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Righi <righiandr@users.sourceforge.net>
Cc: Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> >> I'm looking for a way to keep track of the processes that fail to
> >> allocate new
> >> virtual memory. What do you think about the following approach
> >> (untested)?
> > Looks like an easy way for users to spam syslogd over and
> > over and over again.
> > At the very least, shouldn't this be dependant on print_fatal_signals?
> 
> Anyway, with print-fatal-signals enabled a user could spam syslogd too, simply
> with a (char *)0 = 0 program, but we could always identify the spam attempts
> logging the process uid...

Yeah well it's all captured by syslogd/klogd and written to a file and
diskspace is cheap.


Folkert van Heusden

-- 
Feeling generous? -> http://www.vanheusden.com/wishlist.php
----------------------------------------------------------------------
Phone: +31-6-41278122, PGP-key: 1F28D8AE, www.vanheusden.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
