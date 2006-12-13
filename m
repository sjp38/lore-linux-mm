Message-ID: <458004D6.7050406@redhat.com>
Date: Wed, 13 Dec 2006 08:49:10 -0500
From: Peter Staubach <staubach@redhat.com>
MIME-Version: 1.0
Subject: Re: Status of buffered write path (deadlock fixes)
References: <45751712.80301@yahoo.com.au>	 <20061207195518.GG4497@ca-server1.us.oracle.com>	 <4578DBCA.30604@yahoo.com.au>	 <20061208234852.GI4497@ca-server1.us.oracle.com>	 <457D20AE.6040107@yahoo.com.au> <457D7EBA.7070005@yahoo.com.au>	 <20061212223109.GG6831@ca-server1.us.oracle.com>	 <457F4EEE.9000601@yahoo.com.au>	 <1165974458.5695.17.camel@lade.trondhjem.org>	 <457F5DD8.3090909@yahoo.com.au> <1165977064.5695.38.camel@lade.trondhjem.org>
In-Reply-To: <1165977064.5695.38.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Mark Fasheh <mark.fasheh@oracle.com>, Linux Memory Management <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, Andrew Morton <akpm@google.com>
List-ID: <linux-mm.kvack.org>

Trond Myklebust wrote:
> On Wed, 2006-12-13 at 12:56 +1100, Nick Piggin wrote:
>   
>> Note that these pages should be *really* rare. Definitely even for normal
>> filesystems I think RMW would use too much bandwidth if it were required
>> for any significant number of writes.
>>     
>
> If file "foo" exists on the server, and contains data, then something
> like
>
> fd = open("foo", O_WRONLY);
> write(fd, "1", 1);
>
> should never need to trigger a read. That's a fairly common workload
> when you think about it (happens all the time in apps that do random
> write).

I have to admit that I've only been paying attention with one eye, but
why doesn't this require a read?  If "foo" is non-zero in size, then
how does the client determine how much data in the buffer to write to
the server?

Isn't RMW required for any i/o which is either not buffer aligned or
a multiple of the buffer size?

    Thanx...

       ps

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
