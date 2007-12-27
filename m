Message-ID: <477403A6.6070208@hp.com>
Date: Thu, 27 Dec 2007 14:57:26 -0500
From: Mark Seger <Mark.Seger@hp.com>
MIME-Version: 1.0
Subject: Re: SLUB
References: <476A850A.1080807@hp.com> <Pine.LNX.4.64.0712201138280.30648@schroedinger.engr.sgi.com> <476AFC6C.3080903@hp.com> <476B122E.7010108@hp.com> <Pine.LNX.4.64.0712211338380.3795@schroedinger.engr.sgi.com> <4773B50B.6060206@hp.com> <4773CBD2.10703@hp.com> <Pine.LNX.4.64.0712271141390.30555@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0712271141390.30555@schroedinger.engr.sgi.com>
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
>>                           <-------- objects --------><----- slabs
>> -----><------ memory ------>
>> Slab Name                     Size   In Use    Avail     Size   Number Used       Total
>> :0000008                         8     2164     2560     4096        5 17312       20480
>>     
>
> The right hand side is okay. Could you list all the slab names that are 
> covered by :00008 on the left side (maybe separated by commas?) Having the 
> :00008 there is ugly. slabinfo can show you a way how to get the names.
>   
here's the challenge - I only want to use a single line per entry AND I 
want all the columns to line up for easy reading (I don't want much do 
I?).  I'll have to do some experiments to see what might look better.  
One thought is to list a 'primary' name (whatever that might mean) in 
the left-hand column and perhaps line up the rest of the other names to 
the right of the total.  Another option could be to just repeat the line 
with each slab entry but that also generates a lot of output and one of 
the other notions behind collectl is to make it real easy to see what's 
going on and repeating information can be confusing.
I'm assuming the way slabinfo gets the names (or at least the way I can 
think of doing it) it so just look for entries in /sys/slab that are links.
>> There are all sorts of other ways to present the data such as percentages,
>> differences, etc. but this is more-or-less the way I did it in the past and
>> the information was useful.  One could also argue that the real key
>> information here is Uses/Total and the rest is just window dressing and I
>> couldn't disagree with that either, but I do think it helps paint a more
>> complete picture.
>>     
>
> I agree.
>   
The neat thing about collectl is it's written in perl and contains lots 
of switches and print statements.  I can easily see additional switches 
that might control how the information is printed, such as the 'node' 
level allocations, but I figure that can come later.

-mark


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
