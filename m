Message-ID: <47740858.7000603@hp.com>
Date: Thu, 27 Dec 2007 15:17:28 -0500
From: Mark Seger <Mark.Seger@hp.com>
MIME-Version: 1.0
Subject: Re: SLUB
References: <476A850A.1080807@hp.com> <Pine.LNX.4.64.0712201138280.30648@schroedinger.engr.sgi.com> <476AFC6C.3080903@hp.com> <476B122E.7010108@hp.com> <Pine.LNX.4.64.0712211338380.3795@schroedinger.engr.sgi.com> <4773B50B.6060206@hp.com> <4773CBD2.10703@hp.com> <Pine.LNX.4.64.0712271141390.30555@schroedinger.engr.sgi.com> <477403A6.6070208@hp.com> <Pine.LNX.4.64.0712271157190.30817@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0712271157190.30817@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


Christoph Lameter wrote:
> On Thu, 27 Dec 2007, Mark Seger wrote:
>
>   
>>> The right hand side is okay. Could you list all the slab names that are
>>> covered by :00008 on the left side (maybe separated by commas?) Having the
>>> :00008 there is ugly. slabinfo can show you a way how to get the names.
>>>   
>>>       
>> here's the challenge - I only want to use a single line per entry AND I want
>> all the columns to line up for easy reading (I don't want much do I?).  I'll
>> have to do some experiments to see what might look better.  One thought is to
>> list a 'primary' name (whatever that might mean) in the left-hand column and
>> perhaps line up the rest of the other names to the right of the total.
>>     
>
> slabinfo has the concept of the "first" name of a slab. See the -f option.
>   
slick!
>> Another option could be to just repeat the line with each slab entry but that
>> also generates a lot of output and one of the other notions behind collectl is
>> to make it real easy to see what's going on and repeating information can be
>> confusing.
>>     
>
> I'd say just pack as much as fit into the space and then create a new line 
> if there are too many aliases of the slab.
>   
lemme play with it some
>> I'm assuming the way slabinfo gets the names (or at least the way I can think
>> of doing it) it so just look for entries in /sys/slab that are links.
>>     
>
> It scans for symlinks pointing to that strange name. Source code for 
> slabinfo is in Documentation/vm/slabinfo.c.
>   
gottcha...
-mark


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
