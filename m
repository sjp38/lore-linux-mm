From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199911251914.LAA27659@google.engr.sgi.com>
Subject: Re: [RFC] mapping parts of shared memory
Date: Thu, 25 Nov 1999 11:14:31 -0800 (PST)
In-Reply-To: <qww3dtuisg4.fsf@sap.com> from "Christoph Rohland" at Nov 25, 99 02:58:19 pm
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Rohland <hans-christoph.rohland@sap.com>
Cc: linux-mm@kvack.org, dledford@redhat.com, ebiederm+eric@ccr.net
List-ID: <linux-mm.kvack.org>

> 
> Hi,
> 
> I was investigating for some time about the possibility to create some
> object which allows me to map and unmap parts of it it in different
> processes. This would help to take advantage of the high memory
> systems with applications like SAP R/3 which uses a small number of
> processes to server many clients. It is now limited by the available
> address space for one process.
>

Lets see if I am understanding the problem right. Currently, you may
have an ia32 box with 8G memory, unfortunately, your server can make
use of at most (say) 3G worth of shared memory. Hence, you are worried
about how to be able to use the other 5G, lets say with more server 
processes.

What prevents your app from creating say 2 shm segments, each around
2.5G or so? That will let you attach in and use about 5G between 2
server processes. What have you lost with this approach that you will
get with the kernel approach?

Kanoj
 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
