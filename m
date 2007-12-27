Message-ID: <47743A10.7080605@hp.com>
Date: Thu, 27 Dec 2007 18:49:36 -0500
From: Mark Seger <Mark.Seger@hp.com>
MIME-Version: 1.0
Subject: collectl and the new slab allocator [slub] statistics
References: <476A850A.1080807@hp.com> <Pine.LNX.4.64.0712201138280.30648@schroedinger.engr.sgi.com> <476AFC6C.3080903@hp.com> <476B122E.7010108@hp.com> <Pine.LNX.4.64.0712211338380.3795@schroedinger.engr.sgi.com> <4773B50B.6060206@hp.com> <4773CBD2.10703@hp.com> <Pine.LNX.4.64.0712271141390.30555@schroedinger.engr.sgi.com> <477403A6.6070208@hp.com> <Pine.LNX.4.64.0712271157190.30817@schroedinger.engr.sgi.com> <47741156.4060500@hp.com> <Pine.LNX.4.64.0712271258340.533@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0712271258340.533@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I hope you don't mind but I changed the subject from the pretty generic 
one of 'slub.

My latest thought about handling the multiple aliases is what if I do 
something like slabinfo - pick a 'primary' one based on a similar 
criteria such as the longest name that isn't 'kmalloc' or that other 
funky format with the size in its name.  Then provide a second option 
that shows the mappings of all the names to the primary ones.  That way 
if you're interested in a particular slab you can always look up its 
mapping.  I would also provide a mechanism for specifying those slabs 
you want to monitor and even if not a 'primary' name it would use that name.

Today's kind of over for me but perhaps I can send out an updated 
prototype format tomorrow.

-mark

Christoph Lameter wrote:
> On Thu, 27 Dec 2007, Mark Seger wrote:
>
>   
>> ok, here's a dumb question...  I've been looking at slabinfo and see a routine
>> called find_one_alias which returns the alias that gets printed with the -f
>> switch.  the only thing is the leading comment says "Find the shortest alias
>> of a slab" but it looks like it returns the longest name.  Did you change the
>> functionality after your wrote the comment?  that'll teach you for commenting
>> your code!  8-)
>>     
>
> Yuck.
>
>   
>> I'm also not sure why it would stop the search when it finds an alias that
>> started with 'kmall'.  Is there some reason you wouldn't want to use any of
>> those names as potential candidates?  Does it really matter how I choose the
>> 'first' name?  It's certainly easy enough to pick the longest, I'm just not
>> sure about the test for 'kmall'.
>>     
>
> Well the kmallocs are generic and just give size information. You want a 
> slab name that is more informative than that. 
>   

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
