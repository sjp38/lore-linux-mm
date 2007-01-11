Message-ID: <45A6020F.6030604@yahoo.com.au>
Date: Thu, 11 Jan 2007 20:23:27 +1100
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [REGRESSION] 2.6.19/2.6.20-rc3 buffered write slowdown
References: <20070110223731.GC44411608@melbourne.sgi.com> <Pine.LNX.4.64.0701101503310.22578@schroedinger.engr.sgi.com> <20070110230855.GF44411608@melbourne.sgi.com> <45A57333.6060904@yahoo.com.au> <20070111003158.GT33919298@melbourne.sgi.com> <45A58DFA.8050304@yahoo.com.au> <20070111063555.GB33919298@melbourne.sgi.com>
In-Reply-To: <20070111063555.GB33919298@melbourne.sgi.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: Christoph Lameter <clameter@sgi.com>, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Thanks. BTW. You didn't cc this to the list, so I won't either in case
you want it kept private.

David Chinner wrote:
> On Thu, Jan 11, 2007 at 12:08:10PM +1100, Nick Piggin wrote:
> 
>>Ahh, sorry to be unclear, I meant:
>>
>>  cat /proc/vmstat > pre
>>  run_test
>>  cat /proc/vmstat > post
> 
> 
> 6 files attached - 2.6.18 pre/post, 2.6.20-rc3 dirty_ratio = 10 pre/post
> and 2.6.20-rc3 dirty_ratio=40 pre/post.
> 
> Cheers,
> 
> Dave.
> 
> 
> ------------------------------------------------------------------------
Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
