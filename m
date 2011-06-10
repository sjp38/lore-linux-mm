Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9F9F36B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 12:43:46 -0400 (EDT)
Date: Fri, 10 Jun 2011 13:43:41 -0300
From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
Message-ID: <20110610164341.GA784@khazad-dum.debian.net>
References: <4DEE27DE.7060004@trash.net>
 <4DEE3859.6070808@fnarfbargle.com>
 <4DEE4538.1020404@trash.net>
 <1307471484.3091.43.camel@edumazet-laptop>
 <4DEEACC3.3030509@trash.net>
 <4DEEBFC2.4060102@fnarfbargle.com>
 <1307505541.3102.12.camel@edumazet-laptop>
 <4DEFAB15.2060905@fnarfbargle.com>
 <20110610025249.GD643@verge.net.au>
 <4DF21002.3040708@teksavvy.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4DF21002.3040708@teksavvy.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Lord <kernel@teksavvy.com>
Cc: Simon Horman <horms@verge.net.au>, Brad Campbell <brad@fnarfbargle.com>, Eric Dumazet <eric.dumazet@gmail.com>, Patrick McHardy <kaber@trash.net>, Bart De Schuymer <bdschuym@pandora.be>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org

On Fri, 10 Jun 2011, Mark Lord wrote:
> Something many of us don't realize is that nearly all Intel chipsets
> have a built-in hardware watchdog timer.  This includes chipset for
> consumer desktop boards as well as the big iron server stuff.
> 
> It's the "i8xx_tco" driver in the kernel enables use of them:

That's the old module name, but yes, it is very useful in desktops and
laptops (when it works).   Server-class hardware will have a baseboard
management unit that can really power-cycle the system instead of just
rebooting.

And test it first before you depend on it triggering at a remote location,
as the firmware might cause the Intel chipset watchdog to actually hang the
box instead of causing a proper reboot (happens on the IBM thinkpad T43, for
example).

-- 
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
