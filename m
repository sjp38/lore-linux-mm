Date: Fri, 16 Feb 2001 16:20:42 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: page locking and error handling
In-Reply-To: <Pine.GSO.4.10.10102151526100.26610-100000@zeus.fh-brandenburg.de>
Message-ID: <Pine.LNX.4.21.0102161603240.682-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roman Zippel <zippel@fh-brandenburg.de>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


On Thu, 15 Feb 2001, Roman Zippel wrote:

> Hi,

<snip>

>    - page locking has to happen completely at the higher layer and keeping
>      multiple pages locked would require something like 1).
>    - this would allow to pass multiple pages at once to the mapping
>      mechanism, as we can easily link several pages together. This
>      actually is all what is needed/wanted for streaming and no need for a
>      heavyweight kiobuf.

At commit_write(), the buffers of the pages which are being writen are
only marked dirty and not necessarily queued to IO. commit_write() will
start writting older dirty buffers with flush_dirty_buffers() if the
system is over a watermark of dirty data, which _may_ write dirty buffers
from the current write() syscall. (O_SYNC is another story..)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
