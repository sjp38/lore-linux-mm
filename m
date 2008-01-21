Message-ID: <4794AB56.60904@redhat.com>
Date: Mon, 21 Jan 2008 09:25:26 -0500
From: Peter Staubach <staubach@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH -v6 2/2] Updating ctime and mtime for memory-mapped files
References: <12006091182260-git-send-email-salikhmetov@gmail.com> <E1JFwnQ-0001FB-2c@pomaz-ex.szeredi.hu> <alpine.LFD.1.00.0801181127000.2957@woody.linux-foundation.org> <200801182332.02945.ioe-lkml@rameria.de> <alpine.LFD.1.00.0801181439330.2957@woody.linux-foundation.org>
In-Reply-To: <alpine.LFD.1.00.0801181439330.2957@woody.linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Oeser <ioe-lkml@rameria.de>, Miklos Szeredi <miklos@szeredi.hu>, peterz@infradead.org, salikhmetov@gmail.com, linux-mm@kvack.org, jakob@unthought.net, linux-kernel@vger.kernel.org, valdis.kletnieks@vt.edu, riel@redhat.com, ksm@42.dk, jesper.juhl@gmail.com, akpm@linux-foundation.org, protasnb@gmail.com, r.e.wolff@bitwizard.nl, hidave.darkstar@gmail.com, hch@infradead.org
List-ID: <linux-mm.kvack.org>

Linus Torvalds wrote:
> On Fri, 18 Jan 2008, Ingo Oeser wrote:
>   
>> Can we get "if the write to the page hits the disk, the mtime has hit the disk
>> already no less than SOME_GRANULARITY before"? 
>>
>> That is very important for computer forensics. Esp. in saving your ass!
>>
>> Ok, now back again to making that fast :-)
>>     
>
> I certainly don't mind it if we have some tighter guarantees, but what I'd 
> want is:
>
>  - keep it simple. Let's face it, Linux has never ever given those 
>    guarantees before, and it's not is if anybody has really cared. Even 
>    now, the issue seems to be more about paper standards conformance than 
>    anything else.
>
>   

I have been working on getting something supported here for
because I have some very large Wall Street customers who do
care about getting the mtime updated because their backups
are getting corrupted.  They are incomplete because although
their applications update files, they don't get backed up
because the mtime never changes.

>  - I get worried about people playing around with the dirty bit in 
>    particular. We have had some really rather nasty bugs here. Most of 
>    which are totally impossible to trigger under normal loads (for 
>    example the old random-access utorrent writable mmap issue from about 
>    a year ago).
>
> So these two issues - the big red danger signs flashing in my brain, 
> coupled with the fact that no application has apparently ever really 
> noticed in the last 15 years - just makes it a case where I'd like each 
> step of the way to be obvious and simple and no larger than really 
> absolutely necessary.

Simple is good.  However, too simple is not good.  I would suggest
that we implement file time updates which make sense and if they
happen to follow POSIX, then nifty, otherwise, oh well.

    Thanx...

       ps

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
