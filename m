Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 57B566B0078
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 14:04:09 -0400 (EDT)
Message-ID: <4DEE6815.7040504@pandora.be>
Date: Tue, 07 Jun 2011 20:04:05 +0200
From: Bart De Schuymer <bdschuym@pandora.be>
MIME-Version: 1.0
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
References: <20110601011527.GN19505@random.random> <alpine.LSU.2.00.1105312120530.22808@sister.anvils> <4DE5DCA8.7070704@fnarfbargle.com> <4DE5E29E.7080009@redhat.com> <4DE60669.9050606@fnarfbargle.com> <4DE60918.3010008@redhat.com> <4DE60940.1070107@redhat.com> <4DE61A2B.7000008@fnarfbargle.com> <20110601111841.GB3956@zip.com.au> <4DE62801.9080804@fnarfbargle.com> <20110601230342.GC3956@zip.com.au> <4DE8E3ED.7080004@fnarfbargle.com> <isavsg$3or$1@dough.gmane.org> <4DE906C0.6060901@fnarfbargle.com> <4DED344D.7000005@pandora.be> <4DED9C23.2030408@fnarfbargle.com> <4DEE27DE.7060004@trash.net> <4DEE3859.6070808@fnarfbargle.com>
In-Reply-To: <4DEE3859.6070808@fnarfbargle.com>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brad Campbell <brad@fnarfbargle.com>
Cc: Patrick McHardy <kaber@trash.net>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org

Op 7/06/2011 16:40, Brad Campbell schreef:
> On 07/06/11 21:30, Patrick McHardy wrote:
>> On 07.06.2011 05:33, Brad Campbell wrote:
>>> On 07/06/11 04:10, Bart De Schuymer wrote:
>>>> Hi Brad,
>>>>
>>>> This has probably nothing to do with ebtables, so please rmmod in case
>>>> it's loaded.
>>>> A few questions I didn't directly see an answer to in the threads I
>>>> scanned...
>>>> I'm assuming you actually use the bridging firewall functionality. So,
>>>> what iptables modules do you use? Can you reduce your iptables 
>>>> rules to
>>>> a core that triggers the bug?
>>>> Or does it get triggered even with an empty set of firewall rules?
>>>> Are you using a stock .35 kernel or is it patched?
>>>> Is this something I can trigger on a poor guy's laptop or does it
>>>> require specialized hardware (I'm catching up on qemu/kvm...)?
>>>
>>> Not specialised hardware as such, I've just not been able to reproduce
>>> it outside of this specific operating scenario.
>>
>> The last similar problem we've had was related to the 32/64 bit compat
>> code. Are you running 32 bit userspace on a 64 bit kernel?
>
> No, 32 bit Guest OS, but a completely 64 bit userspace on a 64 bit 
> kernel.
>
> Userspace is current Debian Stable. Kernel is Vanilla and qemu-kvm is 
> current git
>
If the bug is easily triggered with your guest os, then you could try to 
capture the traffic with wireshark (or something else) in a 
configuration that doesn't crash your system. Save the traffic in a pcap 
file. Then you can see if resending that traffic in the vulnerable 
configuration triggers the bug (I don't know if something in Windows 
exists, but tcpreplay should work for Linux). Once you have such a 
capture , chances are the bug is even easily reproducible by us (unless 
it's hardware-specific). Success isn't guaranteed, but I think it's 
worth a shot...

cheers,
Bart


-- 
Bart De Schuymer
www.artinalgorithms.be

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
