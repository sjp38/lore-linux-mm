Date: Sat, 5 Jun 2004 12:21:35 -0700 (PDT)
From: Ron Maeder <rlm@orionmulti.com>
Subject: Re: mmap() > phys mem problem
In-Reply-To: <40B9A855.3030102@yahoo.com.au>
Message-ID: <Pine.LNX.4.60.0406051219130.749@stimpy>
References: <Pine.LNX.4.44.0405251523250.18898-100000@pygar.sc.orionmulti.com>
 <Pine.LNX.4.55L.0405282208210.32578@imladris.surriel.com>
 <Pine.LNX.4.60.0405292144350.1068@stimpy> <40B9A855.3030102@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Rik van Riel <riel@surriel.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Thanks very much for your response.  I have had some help trying out the 
patch and running recent versions of the kernel.  The problem is not fixed 
in 2.6.6+patch or in 2.6.7-rc2.  Any other suggestions?

Ron

On Sun, 30 May 2004, Nick Piggin wrote:

> Ron Maeder wrote:
>> On Fri, 28 May 2004, Rik van Riel wrote:
>> 
>>> On Tue, 25 May 2004, Ron Maeder wrote:
>>> 
>>>> Is this an "undocumented feature" or is this a linux error?  I would
>>>> expect pages of the mmap()'d file would get paged back to the original
>>>> file. I know this won't be fast, but the performance is not an issue 
>>>> for
>>>> this application.
>>> 
>>> 
>>> It looks like a kernel bug.  Can you reproduce this problem
>>> with the latest 2.6 kernel or is it still there ?
>>> 
>>> Rik
>> 
>> 
>> I was able to reproduce the problem with the code that I posted on a 2.6.6
>> kernel.
>> 
>
> Can you give this NFS patch (from Trond) a try please?
>
> (I don't think it is a very good idea for NFS to be using
> WRITEPAGE_ACTIVATE here. If NFS needs to have good write
> clustering off the end of the LRU, we need to go about it
> some other way.)
>
>
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
