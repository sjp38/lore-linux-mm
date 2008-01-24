Message-ID: <4798AC4E.4060307@qumranet.com>
Date: Thu, 24 Jan 2008 17:18:38 +0200
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [kvm-devel] [PATCH] export notifier #1
References: <20080117193252.GC24131@v2.random>	<20080121125204.GJ6970@v2.random> <4795F9D2.1050503@qumranet.com>	<20080122144332.GE7331@v2.random>	<20080122200858.GB15848@v2.random>	<Pine.LNX.4.64.0801221232040.28197@schroedinger.engr.sgi.com>	<20080122223139.GD15848@v2.random>	<Pine.LNX.4.64.0801221433080.2271@schroedinger.engr.sgi.com>	<20080123114136.GE15848@v2.random>	<Pine.LNX.4.64.0801231149150.13547@schroedinger.engr.sgi.com>	<20080124143454.GN7141@v2.random> <4798AB96.4000408@qumranet.com>
In-Reply-To: <4798AB96.4000408@qumranet.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Andrew Morton <akpm@osdl.org>, Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, steiner@sgi.com, linux-kernel@vger.kernel.org, kvm-devel@lists.sourceforge.net, daniel.blueman@quadrics.com, holt@sgi.com, Hugh Dickins <hugh@veritas.com>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

Avi Kivity wrote:
> Andrea Arcangeli wrote:
>   
>> The remote page fault
>>   
>>     
>
> As we have two names for this ('shadow' and 'remote/export') I'd like to 
> suggest a neutral nomenclature.  How about 'secondary mmu' (and 
> secondary ptes (sptes), etc.)?  I think this fits xpmem, kvm, rdma, and dri.
>
>   

Er, it was Robin who came up with this first, I see.  Let's just say I 
second the motion.

-- 
Any sufficiently difficult bug is indistinguishable from a feature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
