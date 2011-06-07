Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id CDB146B00E7
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 09:30:16 -0400 (EDT)
Message-ID: <4DEE27DE.7060004@trash.net>
Date: Tue, 07 Jun 2011 15:30:06 +0200
From: Patrick McHardy <kaber@trash.net>
MIME-Version: 1.0
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
References: <20110601011527.GN19505@random.random> <alpine.LSU.2.00.1105312120530.22808@sister.anvils> <4DE5DCA8.7070704@fnarfbargle.com> <4DE5E29E.7080009@redhat.com> <4DE60669.9050606@fnarfbargle.com> <4DE60918.3010008@redhat.com> <4DE60940.1070107@redhat.com> <4DE61A2B.7000008@fnarfbargle.com> <20110601111841.GB3956@zip.com.au> <4DE62801.9080804@fnarfbargle.com> <20110601230342.GC3956@zip.com.au> <4DE8E3ED.7080004@fnarfbargle.com> <isavsg$3or$1@dough.gmane.org> <4DE906C0.6060901@fnarfbargle.com> <4DED344D.7000005@pandora.be> <4DED9C23.2030408@fnarfbargle.com>
In-Reply-To: <4DED9C23.2030408@fnarfbargle.com>
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brad Campbell <brad@fnarfbargle.com>
Cc: Bart De Schuymer <bdschuym@pandora.be>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org

On 07.06.2011 05:33, Brad Campbell wrote:
> On 07/06/11 04:10, Bart De Schuymer wrote:
>> Hi Brad,
>>
>> This has probably nothing to do with ebtables, so please rmmod in case
>> it's loaded.
>> A few questions I didn't directly see an answer to in the threads I
>> scanned...
>> I'm assuming you actually use the bridging firewall functionality. So,
>> what iptables modules do you use? Can you reduce your iptables rules to
>> a core that triggers the bug?
>> Or does it get triggered even with an empty set of firewall rules?
>> Are you using a stock .35 kernel or is it patched?
>> Is this something I can trigger on a poor guy's laptop or does it
>> require specialized hardware (I'm catching up on qemu/kvm...)?
> 
> Not specialised hardware as such, I've just not been able to reproduce
> it outside of this specific operating scenario.

The last similar problem we've had was related to the 32/64 bit compat
code. Are you running 32 bit userspace on a 64 bit kernel?

> I can't trigger it with empty firewall rules as it relies on a DNAT to
> occur. If I try it directly to the internal IP address (as I have to
> without netfilter loaded) then of course nothing fails.
> 
> It's a pain in the bum as a fault, but it's one I can easily reproduce
> as long as I use the same set of circumstances.
> 
> I'll try using 3.0-rc2 (current git) tonight, and if I can reproduce it
> on that then I'll attempt to pare down the IPTABLES rules to a bare
> minimum.
> 
> It is nothing to do with ebtables as I don't compile it. I'm not really
> sure about "bridging firewall" functionality. I just use a couple of
> hand coded bash scripts to set the tables up.

>From one of your previous mails:

> # CONFIG_BRIDGE_NF_EBTABLES is not set

How about CONFIG_BRIDGE_NETFILTER?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
