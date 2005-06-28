Message-ID: <42C1D8F4.2010601@yahoo.com.au>
Date: Wed, 29 Jun 2005 09:10:44 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 2] mm: speculative get_page
References: <42C0AAF8.5090700@yahoo.com.au> <20050628040608.GQ3334@holomorphy.com> <42C0D717.2080100@yahoo.com.au> <20050627.220827.21920197.davem@davemloft.net> <20050628141903.GR3334@holomorphy.com> <42C17028.6050903@yahoo.com.au> <Pine.LNX.4.62.0506280959100.10511@graphe.net>
In-Reply-To: <Pine.LNX.4.62.0506280959100.10511@graphe.net>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Anton Blanchard <anton@samba.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Wed, 29 Jun 2005, Nick Piggin wrote:
> 
> 
>>But nit picking aside, is it true that we need a load barrier before
>>unlock? (store barrier I agree with) The ppc64 changeset in question
>>indicates yes, but I can't quite work out why. There are noises in the
>>archives about this, but I didn't pinpoint a conclusion...
> 
> 
> A spinlock may be used to read a consistent set of variables. If load
> operations would be moved below the spin_unlock then one may get values
> that have been updated after another process acquired the spinlock.
> 
> 

Of course, thanks. I was only thinking of the case where loads
were moved from the unlocked into the locked section.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
