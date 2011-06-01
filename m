Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2B7E16B0011
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 07:52:46 -0400 (EDT)
Message-ID: <4DE62801.9080804@fnarfbargle.com>
Date: Wed, 01 Jun 2011 19:52:33 +0800
From: Brad Campbell <lists2009@fnarfbargle.com>
MIME-Version: 1.0
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
References: <alpine.LSU.2.00.1105311517480.21107@sister.anvils> <4DE589C5.8030600@fnarfbargle.com> <20110601011527.GN19505@random.random> <alpine.LSU.2.00.1105312120530.22808@sister.anvils> <4DE5DCA8.7070704@fnarfbargle.com> <4DE5E29E.7080009@redhat.com> <4DE60669.9050606@fnarfbargle.com> <4DE60918.3010008@redhat.com> <4DE60940.1070107@redhat.com> <4DE61A2B.7000008@fnarfbargle.com> <20110601111841.GB3956@zip.com.au>
In-Reply-To: <20110601111841.GB3956@zip.com.au>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: CaT <cat@zip.com.au>
Cc: Avi Kivity <avi@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm <linux-mm@kvack.org>, netdev <netdev@vger.kernel.org>

On 01/06/11 19:18, CaT wrote:
> On Wed, Jun 01, 2011 at 06:53:31PM +0800, Brad Campbell wrote:
>> I rebooted into a netfilter kernel, and did all the steps I'd used
>> on the no-netfilter kernel and it ticked along happily.
>>
>> So the result of the experiment is inconclusive. Having said that,
>> the backtraces certainly smell networky.
>>
>> To get it to crash, I have to start IE in the VM and https to the
>> public address of the machine, which is then redirected by netfilter
>> back into another of the VM's.
>>
>> I can https directly to the other VM's address, but that does not
>> cause it to crash, however without netfilter loaded I can't bounce
>> off the public IP. It's all rather confusing really.
>>
>> What next Sherlock?
>
> I think you're hitting something I've seen. Can you try rewriting
> your firewall rules so that it does not reference any bridge
> interfaces at all. Instead, reference the real interface names
> in their place. I'm betting it wont crash.
>

Unfortunately the only interface that is mentioned by name anywhere in 
my firewall is $DMZ (which is ppp0 and not part of any bridge).

All of the nat/dnat and other horrible hacks are based on IP addresses.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
