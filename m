Received: from burns.conectiva (burns.conectiva [10.0.0.4])
	by perninha.conectiva.com.br (Postfix) with SMTP id 6A9C138C48
	for <Linux-MM@kvack.org>; Tue, 31 Jul 2001 01:40:39 -0300 (EST)
Date: Tue, 31 Jul 2001 01:40:39 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: Re: How to memory-map > 2GB Files
In-Reply-To: <3B663266.E2716B2A@scicmp.com>
Message-ID: <Pine.LNX.4.33L.0107310139080.5582-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Himanshu Prakash <himanshu@scicmp.com>
Cc: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 30 Jul 2001, Himanshu Prakash wrote:

> I am in need to memory-map the files of size greater than 2GB on
> 32-bit Operating System. Is it possible?

Barely ...

> Is there any other solution instead of using Memory-mapped
> files, while retaining same read & write speed?

You could map the file in chunks. Mapping several 256MB
chunks at the same time and mapping/unmapping these chunks
on demand should give you both the ability to handle really
huge files and the read & write speed of mmap().

In fact, with this method you should be able to use files
of up to 1TB on 32 bit machines ;)

regards,

Rik
--
Executive summary of a recent Microsoft press release:
   "we are concerned about the GNU General Public License (GPL)"


		http://www.surriel.com/
http://www.conectiva.com/	http://distro.conectiva.com/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
