Date: Sat, 22 Apr 2000 18:37:29 -0700
Subject: Re: mmap64?
From: Jason Titus <jason.titus@av.com>
Message-ID: <B527A1E9.56B9%jason.titus@av.com>
In-Reply-To: <Pine.LNX.4.21.0004221830080.20850-100000@duckman.conectiva>
Mime-version: 1.0
Content-type: text/plain; charset="US-ASCII"
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Well, seems like if we are allowing processes to access 3+GB, we should be
able to mmap a similar range.  Also, I don't know too much about the PAE 36
bit PIII stuff but I had thought it might give us some additional address
space...

Jason
jason.titus@av.com

> From: Rik van Riel <riel@conectiva.com.br>
> Reply-To: riel@nl.linux.org
> Date: Sat, 22 Apr 2000 18:30:35 -0300 (BRST)
> To: Jason Titus <jason.titus@av.com>
> Cc: linux-mm@kvack.org
> Subject: Re: mmap64?
> 
> On Sat, 22 Apr 2000, Jason Titus wrote:
> 
>> We have been doing some work with > 2GB files under x86 linux and have run
>> into a fair number of issues (instability, non-functioning stat calls, etc).
>> 
>> One that just came up recently is whether it is possible to
>> memory map >2GB files.  Is this a possibility, or will this
>> never happen on 32 bit platforms?
> 
> Eurhmm, exactly where in the address space of your process are
> you going to map this file?
> 
> Rik
> --
> The Internet is not a network of computers. It is a network
> of people. That is its real strength.
> 
> Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
> http://www.conectiva.com/  http://www.surriel.com/
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux.eu.org/Linux-MM/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
