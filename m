Message-ID: <44C68F0E.2050100@redhat.com>
Date: Tue, 25 Jul 2006 17:37:18 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: inactive-clean list
References: <1153167857.31891.78.camel@lappy> <44C30E33.2090402@redhat.com> <Pine.LNX.4.64.0607241109190.25634@schroedinger.engr.sgi.com> <44C518D6.3090606@redhat.com> <Pine.LNX.4.64.0607251324140.30939@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0607251324140.30939@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Mon, 24 Jul 2006, Rik van Riel wrote:
> 
>>> I think there may be a way with less changes to the way the VM functions to
>>> get there:
>> That approach probably has way too many state changes going
>> between the guest OS and the hypervisor...
> 
> An increment of a VM counter causes a state change in the hypervisor?

Christoph, please read more than the first 5 words in each
email before replying.

-- 
"Debugging is twice as hard as writing the code in the first place.
Therefore, if you write the code as cleverly as possible, you are,
by definition, not smart enough to debug it." - Brian W. Kernighan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
