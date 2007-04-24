Message-ID: <462D91EA.7030003@redhat.com>
Date: Tue, 24 Apr 2007 01:13:14 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] lazy freeing of memory through MADV_FREE
References: <46247427.6000902@redhat.com>	<20070420135715.f6e8e091.akpm@linux-foundation.org>	<462932BE.4020005@redhat.com>	<20070420150618.179d31a4.akpm@linux-foundation.org>	<4629524C.5040302@redhat.com>	<462ACA40.8070407@yahoo.com.au>	<462B0156.9020407@redhat.com>	<462BFAF3.4040509@yahoo.com.au>	<462C2DC7.5070709@redhat.com>	<462C2F33.8090508@redhat.com>	<462C7A6F.9030905@redhat.com>	<462C88B1.8080906@yahoo.com.au>	<462C8B0A.8060801@redhat.com>	<462C8BFF.2050405@yahoo.com.au>	<462C8E1D.8000706@redhat.com>	<462D5A2E.5060908@yahoo.com.au>	<462D643C.5020709@redhat.com> <17965.35482.107374.228339@cargo.ozlabs.ibm.com>
In-Reply-To: <17965.35482.107374.228339@cargo.ozlabs.ibm.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, shak <dshaks@redhat.com>, jakub@redhat.com, drepper@redhat.com
List-ID: <linux-mm.kvack.org>

Paul Mackerras wrote:
> Rik van Riel writes:
> 
>> I guess we'll need to call tlb_remove_tlb_entry() inside the
>> MADV_FREE code to keep powerpc happy.
> 
> I don't see why; once ptep_test_and_clear_young has returned, the
> entry in the hash table has already been removed. 

OK, so this one won't be necessary. Good to know that.

Andrew, it looks like things won't be that bad :)

-- 
Politics is the struggle between those who want to make their country
the best in the world, and those who believe it already is.  Each group
calls the other unpatriotic.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
