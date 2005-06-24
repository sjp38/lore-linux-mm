Message-ID: <42BB610E.8000705@yahoo.com.au>
Date: Fri, 24 Jun 2005 11:25:34 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch][rfc] 5/5: core remove PageReserved
References: <42BA5F37.6070405@yahoo.com.au> <42BA5F5C.3080101@yahoo.com.au> <42BA5F7B.30904@yahoo.com.au> <42BA5FA8.7080905@yahoo.com.au> <42BA5FC8.9020501@yahoo.com.au> <42BA5FE8.2060207@yahoo.com.au> <20050623095153.GB3334@holomorphy.com> <42BA8FA5.2070407@yahoo.com.au> <20050623220812.GD3334@holomorphy.com> <42BB43FB.1060609@yahoo.com.au> <20050624005952.GE3334@holomorphy.com>
In-Reply-To: <20050624005952.GE3334@holomorphy.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Hugh Dickins <hugh@veritas.com>, Badari Pulavarty <pbadari@us.ibm.com>
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:

>>I wouldn't pretend to be able to fix every bug everywhere in the
>>kernel myself.
> 

> If you can't handle the sweep, you have no business writing the patch.
> 

Let me just say that where I have introduced incompatibilities
I will try to look through drivers and arch code. I can't look
through and find everything that is already buggy though.

Send instant messages to your online friends http://au.messenger.yahoo.com 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
