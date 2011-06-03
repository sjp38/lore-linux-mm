Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 644FF6B004A
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 09:39:10 -0400 (EDT)
Message-ID: <4DE8E3ED.7080004@fnarfbargle.com>
Date: Fri, 03 Jun 2011 21:38:53 +0800
From: Brad Campbell <lists2009@fnarfbargle.com>
MIME-Version: 1.0
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
References: <20110601011527.GN19505@random.random> <alpine.LSU.2.00.1105312120530.22808@sister.anvils> <4DE5DCA8.7070704@fnarfbargle.com> <4DE5E29E.7080009@redhat.com> <4DE60669.9050606@fnarfbargle.com> <4DE60918.3010008@redhat.com> <4DE60940.1070107@redhat.com> <4DE61A2B.7000008@fnarfbargle.com> <20110601111841.GB3956@zip.com.au> <4DE62801.9080804@fnarfbargle.com> <20110601230342.GC3956@zip.com.au>
In-Reply-To: <20110601230342.GC3956@zip.com.au>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: CaT <cat@zip.com.au>
Cc: Avi Kivity <avi@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm <linux-mm@kvack.org>, netdev <netdev@vger.kernel.org>

On 02/06/11 07:03, CaT wrote:
> On Wed, Jun 01, 2011 at 07:52:33PM +0800, Brad Campbell wrote:
>> Unfortunately the only interface that is mentioned by name anywhere
>> in my firewall is $DMZ (which is ppp0 and not part of any bridge).
>>
>> All of the nat/dnat and other horrible hacks are based on IP addresses.
>
> Damn. Not referencing the bridge interfaces at all stopped our host from
> going down in flames when we passed it a few packets. These are two
> of the oopses we got from it. Whilst the kernel here is .35 we got the
> same issue from a range of kernels. Seems related.

Well, I tried sending an explanatory message to netdev, netfilter & cc'd 
to kvm, but it appears not to have made it to kvm or netfilter, and the 
cc to netdev has not elicited a response. My resend to netfilter seems 
to have dropped into the bit bucket also.

Is there anyone who can point me at the appropriate cage to rattle? I 
know it appears to be a netfilter issue, but I don't seem to be able to 
get a message to the list (and I am subscribed to it and have been 
getting mail for months) and I'm not sure who to pester. The other 
alternative is I just stop doing "that" and wait for it to bite someone 
else.

Cheers.
Brad

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
