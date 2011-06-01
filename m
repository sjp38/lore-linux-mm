Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 7F48D6B0011
	for <linux-mm@kvack.org>; Wed,  1 Jun 2011 06:53:47 -0400 (EDT)
Message-ID: <4DE61A2B.7000008@fnarfbargle.com>
Date: Wed, 01 Jun 2011 18:53:31 +0800
From: Brad Campbell <lists2009@fnarfbargle.com>
MIME-Version: 1.0
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
References: <4DE44333.9000903@fnarfbargle.com> <20110531054729.GA16852@liondog.tnic> <4DE4B432.1090203@fnarfbargle.com> <20110531103808.GA6915@eferding.osrc.amd.com> <4DE4FA2B.2050504@fnarfbargle.com> <alpine.LSU.2.00.1105311517480.21107@sister.anvils> <4DE589C5.8030600@fnarfbargle.com> <20110601011527.GN19505@random.random> <alpine.LSU.2.00.1105312120530.22808@sister.anvils> <4DE5DCA8.7070704@fnarfbargle.com> <4DE5E29E.7080009@redhat.com> <4DE60669.9050606@fnarfbargle.com> <4DE60918.3010008@redhat.com> <4DE60940.1070107@redhat.com>
In-Reply-To: <4DE60940.1070107@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Avi Kivity <avi@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org, kvm@vger.kernel.org, linux-mm <linux-mm@kvack.org>

On 01/06/11 17:41, Avi Kivity wrote:
> On 06/01/2011 12:40 PM, Avi Kivity wrote:
>>
>> bridge and netfilter, IIRC this was also the problem last time.
>>
>> Do you have any ebtables loaded?

Never heard of them, but making a cursory check just in case..

brad@srv:/raid10/src/linux-2.6.39$ grep EBTABLE .config
# CONFIG_BRIDGE_NF_EBTABLES is not set

>> Can you try building a kernel without ebtables? Without netfilter at all?

Well, without netfilter I can't get it to crash. The problem is without 
netfilter I can't actually use it the way I use it to get it to crash.

I rebooted into a netfilter kernel, and did all the steps I'd used on 
the no-netfilter kernel and it ticked along happily.

So the result of the experiment is inconclusive. Having said that, the 
backtraces certainly smell networky.

To get it to crash, I have to start IE in the VM and https to the public 
address of the machine, which is then redirected by netfilter back into 
another of the VM's.

I can https directly to the other VM's address, but that does not cause 
it to crash, however without netfilter loaded I can't bounce off the 
public IP. It's all rather confusing really.

What next Sherlock?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
