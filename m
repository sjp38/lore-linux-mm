Subject: Re: mmap64?
References: <B5274D15.56A6%jason.titus@av.com>
From: ebiederm+eric@ccr.net (Eric W. Biederman)
Date: 22 Apr 2000 20:24:13 -0500
In-Reply-To: Jason Titus's message of "Sat, 22 Apr 2000 12:35:33 -0700"
Message-ID: <m1zoqlhao2.fsf@flinx.biederman.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jason Titus <jason.titus@av.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jason Titus <jason.titus@av.com> writes:

> We have been doing some work with > 2GB files under x86 linux and have run
> into a fair number of issues (instability, non-functioning stat calls, etc).

Well it's a 2.3.x is a development kernel...

> 
> One that just came up recently is whether it is possible to memory map >2GB
> files.  Is this a possibility, or will this never happen on 32 bit
> platforms?

sys_mmap2 should work just fine...

Eric
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
