Subject: Re: the new VM
References: <Pine.LNX.4.21.0009251135390.14614-100000@duckman.distro.conectiva>
From: Christoph Rohland <cr@sap.com>
Date: 25 Sep 2000 22:34:11 +0200
In-Reply-To: Rik van Riel's message of "Mon, 25 Sep 2000 11:37:18 -0300 (BRST)"
Message-ID: <qwwlmwgjjng.fsf@sap.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Hi Rik,

Rik van Riel <riel@conectiva.com.br> writes:

> > Because as you said the machine can lockup when you run out of memory.
> 
> The fix for this is to kill a user process when you're OOM
> (you need to do this anyway).
> 
> The last few allocations of the "condemned" process can come
> frome the reserved pages and the process we killed will exit just
> fine.

It's slightly offtopic, but you should think about detached shm
segments in yout OOM killer. As many of the high end applications like
databases and e.g. SAP have most of the memory in shm segments you
easily end up killing a lot of processes without freeing a lot of
memory. I see this often in my shm tests.

Greetings
                Christoph

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
