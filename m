Date: Mon, 24 Apr 2000 19:07:54 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: mmap64?
Message-ID: <20000424190754.B1566@redhat.com>
References: <B5274D15.56A6%jason.titus@av.com> <Pine.LNX.4.21.0004221830080.20850-100000@duckman.conectiva>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0004221830080.20850-100000@duckman.conectiva>; from riel@conectiva.com.br on Sat, Apr 22, 2000 at 06:30:35PM -0300
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: Jason Titus <jason.titus@av.com>, linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Sat, Apr 22, 2000 at 06:30:35PM -0300, Rik van Riel wrote:
> 
> Eurhmm, exactly where in the address space of your process are
> you going to map this file?

mmap64() is defined to allow you to map arbitrary regions of large
files into your address space.  You don't have to map the whole
file.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
