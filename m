Message-ID: <43AAE555.9070808@superbug.demon.co.uk>
Date: Thu, 22 Dec 2005 17:41:41 +0000
From: James Courtier-Dutton <James@superbug.demon.co.uk>
MIME-Version: 1.0
Subject: Re: Possible cure for memory fragmentation.
References: <43A9409D.1010904@superbug.demon.co.uk> <Pine.LNX.4.62.0512211058350.2455@schroedinger.engr.sgi.com> <43AAC5EA.3090800@superbug.demon.co.uk> <Pine.LNX.4.62.0512220908120.7717@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.62.0512220908120.7717@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@engr.sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> Umm. When would the kernel do something like that? 
> Also give it different name. realloc has pretty well established 
> semantics.

Ok, I will call is kmovefrag() for lack of any better name at the moment.

> 
> 
>>If the kernel does not wish to move it, kremalloc returns without having done
>>anything.
> 
> 
> What this all comes down to is to guarantee that only a known number of 
> references exist to the data element when you move it. For kremalloc these
> references must be known and all the pointers to the data element must be 
> updated if the data is moved. The basic problem is not solved.
> 
> 
Surely the module that originally called kmalloc should have enough 
information to know who is then using the memory pointer, or it could be 
redesigned to know enough.
It is therefore my suggestion that the module that originally requested 
the kmalloc() call kmovefrag() at a time that suits it( probably 
periodically), therefore allowing the kernel to move the fragment if it 
wishes. The module that called kmovefrag() can then update all it's 
pointers and continue.

It requires implementing kmovefrag() calls all over the different 
modules, but this goes some way to solving the "basic problem."

James

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
