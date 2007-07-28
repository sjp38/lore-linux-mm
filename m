Message-ID: <46AAD1F7.50801@gmail.com>
Date: Sat, 28 Jul 2007 07:19:51 +0200
From: Rene Herman <rene.herman@gmail.com>
MIME-Version: 1.0
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans
 for 2.6.23]
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com> <200707271345.55187.dhazelton@enter.net> <46AA3680.4010508@gmail.com> <200707271628.46804.dhazelton@enter.net>
In-Reply-To: <200707271628.46804.dhazelton@enter.net>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Hazelton <dhazelton@enter.net>
Cc: Mike Galbraith <efault@gmx.de>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, Frank Kingswood <frank@kingswood-consulting.co.uk>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ray Lee <ray-lk@madrabbit.org>, Jesper Juhl <jesper.juhl@gmail.com>, ck list <ck@vds.kolivas.org>, Paul Jackson <pj@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, B.Steinbrink@gmx.de
List-ID: <linux-mm.kvack.org>

On 07/27/2007 10:28 PM, Daniel Hazelton wrote:

> Check the attitude at the door then re-read what I actually said:

Attitude? You wanted attitude dear boy?

>>> Updatedb or another process that uses the FS heavily runs on a users
>>> 256MB P3-800 (when it is idle) and the VFS caches grow, causing memory
>>> pressure that causes other applications to be swapped to disk. In the
>>> morning the user has to wait for the system to swap those applications
>>> back in.
> 
> I never said that it was the *program* itself - or *any* specific program (I 
> used "Updatedb" because it has been the big name in the discussion) - doing 
> the filling of memory. I actually said that the problem is that the kernel's 
> caches - VFS and others - will grow *WITHOUT* *LIMIT*, filling all available 
> memory. 

WHICH SWAP-PREFETCH DOES NOT HELP WITH.
WHICH SWAP-PREFETCH DOES NOT HELP WITH.
WHICH SWAP-PREFETCH DOES NOT HELP WITH.

And now finally get that through your thick scull or shut up, right fucking now.

> You want to know what causes the problem? The current design of the caches. 
> They will extend without much limit, to the point of actually pushing pages 
> to disk so they can grow even more. 

Due to being a generally nice guy, I am going to try _once_ more to try and 
make you understand. Not twice, once. So pay attention. Right now.

Those caches are NOT causing any problem under discussion. If any caches 
grow to the point of causing swap-out, they have filled memory and 
swap-prefetch cannot and will not do anything since it needs free (as in not 
occupied by caches) memory. As such, people maintaining that swap-prefetch 
helps their situation are not being hit by caches.

The only way swap-prefetch can (and will) do anything is when something that 
by itself takes up lots of memory runs and exits. So can we now please 
finally drop the fucking red herring and start talking about swap-prefetch?

If we accept that some of the people maintaining that swap-prefetch helps 
them are not in fact deluded -- a bit of a stretch seeing as how not a 
single one of them is substantiating anything -- we have a number of 
slightly different possibilities for "something" in the above.

-- 1)

It could be an inefficient updatedb. Although he isn't experiencing the 
problem, Bjoern Steinbrink is posting numbers (weeee!) that show that at 
least the GNU version spawns a large memory "sort" process meaning that on a 
low-memory box updatedb itself can be what causes the observed problem.

While in this situation switching to a different updatedb (slocate, mlocate) 
obviously makes sense it's the kind of situation where swap-prefetch will help.

-- 2)

It could be something else entirely such as a backup run. I suppose people 
would know if they were running anything of the sort though and wouldn't 
blaim anything on updatedb.

Other than that, it's again the situation where swap-prefetch would help.

-- 3)

The something else entirely can also run _after_ updatedb, kicking out the 
VFS caches and leaving free memory upon exit. I still suppose the same thing 
as under (2) but this is the only way how updatedb / VFS caches can even be 
part of any problem, if the _combined_ memory pressure is just enough to 
make the difference.

The direct problem is still just the "something else entirely" and needs 
someone affected to tell us what it is.

> I already did. You completely ignored it because I happened to use the magic 
> words "updatedb" and "swap prefetch". 

No I did not. This thread is about swap-prefetch and you used the magic 
words VFS caches. I don't give a fryin' fuck if their filling is caused by 
updatedb or the cat sleeping on the "find /<enter>" keys on your keyboard, 
they're still not causing anything swap-prefetch helps with.

This thread has seen input from a selection of knowledgeable people and 
Morton was even running benchmarks to look at this supposed VFS cache 
problem and not finding it. The only further input this thread needs is 
someone affected by the supposed problem.

Which I ofcourse notice in a followup of yours you are not either -- you're 
just here to blabber, not to solve anything.

Rene.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
