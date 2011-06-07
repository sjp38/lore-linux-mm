Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 771006B004A
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 19:44:09 -0400 (EDT)
Message-ID: <4DEEB7BF.9000801@fnarfbargle.com>
Date: Wed, 08 Jun 2011 07:43:59 +0800
From: Brad Campbell <brad@fnarfbargle.com>
MIME-Version: 1.0
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
References: <20110601011527.GN19505@random.random> <alpine.LSU.2.00.1105312120530.22808@sister.anvils> <4DE5DCA8.7070704@fnarfbargle.com> <4DE5E29E.7080009@redhat.com> <4DE60669.9050606@fnarfbargle.com> <4DE60918.3010008@redhat.com> <4DE60940.1070107@redhat.com> <4DE61A2B.7000008@fnarfbargle.com> <20110601111841.GB3956@zip.com.au> <4DE62801.9080804@fnarfbargle.com> <20110601230342.GC3956@zip.com.au> <4DE8E3ED.7080004@fnarfbargle.com> <isavsg$3or$1@dough.gmane.org> <4DE906C0.6060901@fnarfbargle.com> <4DED344D.7000005@pandora.be> <4DED9C23.2030408@fnarfbargle.com> <4DEE27DE.7060004@trash.net> <4DEE3859.6070808@fnarfbargle.com> <4DEE4538.1020404@trash.net>
In-Reply-To: <4DEE4538.1020404@trash.net>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Patrick McHardy <kaber@trash.net>
Cc: Bart De Schuymer <bdschuym@pandora.be>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org

On 07/06/11 23:35, Patrick McHardy wrote:

> The main suspects would be NAT and TCPMSS. Did you also try whether
> the crash occurs with only one of these these rules?

To be honest I'm actually having trouble finding where TCPMSS is 
actually set in that ruleset. This is a production machine so I can only 
take it down after about 9PM at night. I'll have another crack at it 
tonight.

>> I've just compiled out CONFIG_BRIDGE_NETFILTER and can no longer access
>> the address the way I was doing it, so that's a no-go for me.
>
> That's really weird since you're apparently not using any bridge
> netfilter features. It shouldn't have any effect besides changing
> at which point ip_tables is invoked. How are your network devices
> configured (specifically any bridges)?
>

I have one bridge with all my virtual machines on it.

In this particular instance the packets leave VM A destined for the IP 
address of ppp0 (the external interface). This is intercepted by the 
DNAT PREROUTING rule above and shunted back to VM B.

The VM's are on br1 and the external address is ppp0. Without 
CONFIG_BRIDGE_NETFILTER compiled in I can see the traffic entering and 
leaving VM B with tcpdump, but the packets never seem to get back to VM A.

VM A is XP 32 bit, VM B is Linux. I have some other Linux VM's, so I'll 
do some more testing tonight between those to see where the packets are 
going without CONFIG_BRIDGE_NETFILTER set.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
