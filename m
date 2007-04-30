Message-ID: <4635433C.7030607@google.com>
Date: Sun, 29 Apr 2007 18:15:40 -0700
From: Ethan Solomita <solo@google.com>
MIME-Version: 1.0
Subject: Re: NR_UNSTABLE_FS vs. NR_FILE_DIRTY: double counting pages?
References: <4632A1A6.90702@google.com> <1177878135.6400.37.camel@heimdal.trondhjem.org> <463537C2.5050804@google.com>
In-Reply-To: <463537C2.5050804@google.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ethan Solomita <solo@google.com>
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ethan Solomita wrote:
> Trond Myklebust wrote:
>>
>> It should not happen. If the page is on the unstable list, then it will
>> be committed before nfs_updatepage is allowed to redirty it. See the
>> recent fixes in 2.6.21-rc7.
> 
>     Above I present a codepath called straight from sys_write() which 
> seems to do what I say. I could be wrong, but can you address the code 
> paths I show above which seem to set both?

	Sorry about my quick reply, I'd misunderstood what you were saying. 
I'll take a look at what you say.

	Thanks,
	-- Ethan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
