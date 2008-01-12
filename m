Message-ID: <47891B8A.3030502@qumranet.com>
Date: Sat, 12 Jan 2008 21:56:58 +0200
From: Avi Kivity <avi@qumranet.com>
MIME-Version: 1.0
Subject: Re: [kvm-devel] mmu notifiers
References: <20080109181908.GS6958@v2.random> <Pine.LNX.4.64.0801091352320.12335@schroedinger.engr.sgi.com> <47860512.3040607@qumranet.com> <20080110131612.GA1933@sgi.com> <47861D3C.6070709@qumranet.com> <Pine.LNX.4.64.0801101105210.20353@schroedinger.engr.sgi.com>
In-Reply-To: <Pine.LNX.4.64.0801101105210.20353@schroedinger.engr.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Robin Holt <holt@sgi.com>, Andrea Arcangeli <andrea@qumranet.com>, kvm-devel@lists.sourceforge.net, linux-mm@kvack.org, Daniel J Blueman <daniel.blueman@quadrics.com>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
>   
>> Excellent, the more users the patch has, the easier it will be to justify it.
>>     
>
> We'd like to make sure though that we can sleep when the hooks have been 
> called. We may have to sent a message to kick remote ptes out when local 
> pte changes happen.
>
>   

It may be as simple as moving the notifier calls down to a sleeping 
context, away from the pte lock and any friends.

kvm also needs to send a message on an mmu notification, but that's just 
an IPI within the same host.

-- 
Any sufficiently difficult bug is indistinguishable from a feature.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
