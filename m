Message-ID: <20020103225927.81907.qmail@web12305.mail.yahoo.com>
Date: Thu, 3 Jan 2002 14:59:27 -0800 (PST)
From: Ravi K <kravi26@yahoo.com>
Subject: Re: Allocation of kernel memory >128K
In-Reply-To: <Pine.LNX.4.21.0112271634010.29530-100000@mailhost.tifr.res.in>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Amit S. Jain" <amitjain@tifr.res.in>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

>   I WANT TO KNOW WHAT AMOUNT OF MEMORY ALLOCATION
> WILL BE SAFE.i.e. even
> if i alloc 30K at a time,will I always get a
> contiguous memory for that
> purpose.??
> 	Is there a set limit in Linux for the amount of
> memory we obtain
> will always be contiguous or always available??

 No, there are no guarantees about availability of
contiguous memory. But if you do not specify
GFP_ATOMIC flag when calling kmalloc(), it will sleep
till the requested amount of memory is available.

Ravi.

__________________________________________________
Do You Yahoo!?
Send your FREE holiday greetings online!
http://greetings.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
