Date: Tue, 6 Jun 2000 22:00:37 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: instrumentation patch for shrink_mmap to find cause of failures
 - it did  :-)
In-Reply-To: <393D867F.87DE4DBC@norran.net>
Message-ID: <Pine.LNX.4.21.0006062158230.10990-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII
Content-ID: <Pine.LNX.4.21.0006062158232.10990@duckman.distro.conectiva>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roger Larsson <roger.larsson@norran.net>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 7 Jun 2000, Roger Larsson wrote:

> What to do about it:
> a) Move the zone check early - buffers may get old...
> b) Undo counting before continuing due to wrong zone

a) is a non-issue since the buffers will get old just as
   well if there's no memory pressure and shrink_mmap
   isn't run

I think your patch (from the other email) is the correct one
for the current MM structure. I'm definately taking your
results into account for the active/inactive/scavenge list
thing I'm working on right now.

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
