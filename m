Date: Sat, 22 Apr 2000 18:52:50 -0700
Subject: Re: mmap64?
From: Jason Titus <jason.titus@av.com>
Message-ID: <B527A582.56BC%jason.titus@av.com>
In-Reply-To: <m1zoqlhao2.fsf@flinx.biederman.org>
Mime-version: 1.0
Content-type: text/plain; charset="US-ASCII"
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


> From: ebiederm+eric@ccr.net (Eric W. Biederman)
> Date: 22 Apr 2000 20:24:13 -0500
> To: Jason Titus <jason.titus@av.com>
> Cc: <linux-mm@kvack.org>
> Subject: Re: mmap64?
> 
> Jason Titus <jason.titus@av.com> writes:
> 
>> We have been doing some work with > 2GB files under x86 linux and have run
>> into a fair number of issues (instability, non-functioning stat calls, etc).
> 
> Well it's a 2.3.x is a development kernel...
> 

This is true.  But I would bet that large file support will be one of the
most noticeable 2.2 -> 2.4 improvements, and it has been a very rough road
so far.  Seems to be working now, and the only two thing that seems to not
work are stat (returns a negative number for >2GB files) and mmap (fails on
2>GB files - perhaps justifiably so...).  I'm just hoping that large file
support will work well by the time 2.4 comes out.  It is one of the main
things that holds Linux back from the enterprise.


>> 
>> One that just came up recently is whether it is possible to memory map >2GB
>> files.  Is this a possibility, or will this never happen on 32 bit
>> platforms?
> 
> sys_mmap2 should work just fine...
> 
I will check that out.

Thanks,
Jason.

> Eric
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
