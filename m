Message-ID: <41EE9991.6090606@mvista.com>
Date: Wed, 19 Jan 2005 09:32:01 -0800
From: Steve Longerbeam <stevel@mvista.com>
MIME-Version: 1.0
Subject: Re: BUG in shared_policy_replace() ?
References: <Pine.LNX.4.44.0501191221400.4795-100000@localhost.localdomain>
In-Reply-To: <Pine.LNX.4.44.0501191221400.4795-100000@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andi Kleen <ak@suse.de>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


Hugh Dickins wrote:

>On Tue, 18 Jan 2005, Steve Longerbeam wrote:
>  
>
>>Why free the shared policy created to split up an old
>>policy that spans the whole new range? Ie, see patch.
>>    
>>
>
>I think you're misreading it.  That code comes from when I changed it
>over from sp->sem to sp->lock.  If it finds that it needs to split an
>existing range, so needs to allocate a new2, then it has to drop and
>reacquire the spinlock around that.  It's conceivable that a racing
>task could change the tree while the spinlock is dropped, in such a
>way that this split is no longer necessary once we reacquire the
>spinlock.  The code you're looking at frees up new2 in that case;
>whereas in the normal case, where it is still needed, there's a
>new2 = NULL after inserting it, so that it won't be freed below.
>  
>

got it, except that there is no "new2 = NULL;" in 2.6.10-mm2!

Looks like it was misplaced, because I do see it now in 2.6.10.

Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
