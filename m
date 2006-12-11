Message-ID: <457D89DA.5010705@yahoo.com.au>
Date: Tue, 12 Dec 2006 03:39:54 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Status of buffered write path (deadlock fixes)
References: <45751712.80301@yahoo.com.au>	 <20061207195518.GG4497@ca-server1.us.oracle.com>	 <4578DBCA.30604@yahoo.com.au>	 <20061208234852.GI4497@ca-server1.us.oracle.com>	 <457D20AE.6040107@yahoo.com.au>  <457D7EBA.7070005@yahoo.com.au> <1165853552.3752.1015.camel@quoit.chygwyn.com>
In-Reply-To: <1165853552.3752.1015.camel@quoit.chygwyn.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Whitehouse <steve@chygwyn.com>
Cc: Mark Fasheh <mark.fasheh@oracle.com>, Linux Memory Management <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>, OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>, Andrew Morton <akpm@google.com>
List-ID: <linux-mm.kvack.org>

Steven Whitehouse wrote:

>>Hmm, doesn't look like we can do this either because at least GFS2
>>uses BH_New for its own special things.
>>
> 
> What makes you say that? As far as I know we are not doing anything we
> shouldn't with this flag, and if we are, then I'm quite happy to
> consider fixing it up so that we don't,

Bad wording. Many other filesystems seem to only make use of buffer_new
between prepare and commit_write.

gfs2 seems to at least test it in a lot of places, so it is hard to know
whether we can change the current semantics or not. I didn't mean that
gfs2 is doing anything wrong.

So can we clear it in commit_write?

-- 
SUSE Labs, Novell Inc.
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
