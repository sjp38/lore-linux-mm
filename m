Date: Sat, 29 May 2004 21:47:03 -0700 (PDT)
From: Ron Maeder <rlm@orionmulti.com>
Subject: Re: mmap() > phys mem problem
In-Reply-To: <Pine.LNX.4.55L.0405282208210.32578@imladris.surriel.com>
Message-ID: <Pine.LNX.4.60.0405292144350.1068@stimpy>
References: <Pine.LNX.4.44.0405251523250.18898-100000@pygar.sc.orionmulti.com>
 <Pine.LNX.4.55L.0405282208210.32578@imladris.surriel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@surriel.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 28 May 2004, Rik van Riel wrote:

> On Tue, 25 May 2004, Ron Maeder wrote:
>
>> Is this an "undocumented feature" or is this a linux error?  I would
>> expect pages of the mmap()'d file would get paged back to the original
>> file. I know this won't be fast, but the performance is not an issue for
>> this application.
>
> It looks like a kernel bug.  Can you reproduce this problem
> with the latest 2.6 kernel or is it still there ?
>
> Rik

I was able to reproduce the problem with the code that I posted on a 2.6.6
kernel.

Ron

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
