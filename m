Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id A20836B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 08:37:27 -0400 (EDT)
Message-ID: <4DF21002.3040708@teksavvy.com>
Date: Fri, 10 Jun 2011 08:37:22 -0400
From: Mark Lord <kernel@teksavvy.com>
MIME-Version: 1.0
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
References: <4DED344D.7000005@pandora.be> <4DED9C23.2030408@fnarfbargle.com> <4DEE27DE.7060004@trash.net> <4DEE3859.6070808@fnarfbargle.com> <4DEE4538.1020404@trash.net> <1307471484.3091.43.camel@edumazet-laptop> <4DEEACC3.3030509@trash.net> <4DEEBFC2.4060102@fnarfbargle.com> <1307505541.3102.12.camel@edumazet-laptop> <4DEFAB15.2060905@fnarfbargle.com> <20110610025249.GD643@verge.net.au>
In-Reply-To: <20110610025249.GD643@verge.net.au>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Horman <horms@verge.net.au>
Cc: Brad Campbell <brad@fnarfbargle.com>, Eric Dumazet <eric.dumazet@gmail.com>, Patrick McHardy <kaber@trash.net>, Bart De Schuymer <bdschuym@pandora.be>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org

On 11-06-09 10:52 PM, Simon Horman wrote:
> On Thu, Jun 09, 2011 at 01:02:13AM +0800, Brad Campbell wrote:
>> On 08/06/11 11:59, Eric Dumazet wrote:
>>
>>> Well, a bisection definitely should help, but needs a lot of time in
>>> your case.
>>
>> Yes. compile, test, crash, walk out to the other building to press
>> reset, lather, rinse, repeat.
>>
>> I need a reset button on the end of a 50M wire, or a hardware watchdog!


Something many of us don't realize is that nearly all Intel chipsets
have a built-in hardware watchdog timer.  This includes chipset for
consumer desktop boards as well as the big iron server stuff.

It's the "i8xx_tco" driver in the kernel enables use of them:

    modprobe i8xx_tco

Cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
