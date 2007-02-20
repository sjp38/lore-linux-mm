Message-ID: <45DB4C87.6050809@redhat.com>
Date: Tue, 20 Feb 2007 14:31:19 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] free swap space when (re)activating page
References: <45D63445.5070005@redhat.com> <Pine.LNX.4.64.0702192048150.9934@schroedinger.engr.sgi.com> <45DAF794.2000209@redhat.com> <Pine.LNX.4.64.0702200833460.13913@schroedinger.engr.sgi.com> <45DB25E1.7030504@redhat.com> <Pine.LNX.4.64.0702201015590.14497@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0702201015590.14497@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Tue, 20 Feb 2007, Rik van Riel wrote:
> 
>> Nono, I try to remove the swap space occupied by pages that
>> go back onto the active list.  Regardless of whether they
>> were already there, or whether they started out on the
>> inactive list.
> 
> Ok then do it for all pages that go back not just for those leftover from 
> the moving of pages to the inactive list (why would you move those???)

I do.  The only pages that are exempt are the pages that move
from the active list to the inactive list, because those will
probably be evicted soon enough.

> Maybe the hunk does apply in a different location than I thought.

I suspect that's the case ...

> If you 
> do that in the loop over the pages on active list then it would make 
> sense. But in that case you need another piece of it doing the same to the 
> pages that are released at the end of shrink_active_list().

... because I think this is what my patch does :)

-- 
All Rights Reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
