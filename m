Date: Wed, 24 Apr 2002 23:19:50 -0300 (BRT)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: memory exhausted
In-Reply-To: <5.1.0.14.2.20020424145006.00b17cb0@notes.tcindex.com>
Message-ID: <Pine.LNX.4.44L.0204242318240.1960-100000@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Vivian Wang <vivianwang@tcindex.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[mailing list address corrected ... won't people ever learn to read ?]

On Wed, 24 Apr 2002, Vivian Wang wrote:

> I try to sort my 11 GB file, but I got message about memory exhausted.
> I used the command like this:
> sort -u file1 -o file2
> Is this correct?

Yes, sort only has a maximum of 3 GB of virtual address space so
it will never be able to load the whole 11 GB file into memory.

> What I should do?

You could either write your own sort program that doesn't need
to have the whole file loaded or you could use a 64 bit machine
with at least 11 GB of available virtual memory, probably the
double...

regards,

Rik
-- 
Bravely reimplemented by the knights who say "NIH".

http://www.surriel.com/		http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
