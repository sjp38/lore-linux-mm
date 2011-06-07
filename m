Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 520466B004A
	for <linux-mm@kvack.org>; Tue,  7 Jun 2011 14:31:37 -0400 (EDT)
Received: by wwi36 with SMTP id 36so4408007wwi.26
        for <linux-mm@kvack.org>; Tue, 07 Jun 2011 11:31:33 -0700 (PDT)
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <4DEE4538.1020404@trash.net>
References: <20110601011527.GN19505@random.random>
	 <alpine.LSU.2.00.1105312120530.22808@sister.anvils>
	 <4DE5DCA8.7070704@fnarfbargle.com> <4DE5E29E.7080009@redhat.com>
	 <4DE60669.9050606@fnarfbargle.com> <4DE60918.3010008@redhat.com>
	 <4DE60940.1070107@redhat.com> <4DE61A2B.7000008@fnarfbargle.com>
	 <20110601111841.GB3956@zip.com.au> <4DE62801.9080804@fnarfbargle.com>
	 <20110601230342.GC3956@zip.com.au> <4DE8E3ED.7080004@fnarfbargle.com>
	 <isavsg$3or$1@dough.gmane.org> <4DE906C0.6060901@fnarfbargle.com>
	 <4DED344D.7000005@pandora.be> <4DED9C23.2030408@fnarfbargle.com>
	 <4DEE27DE.7060004@trash.net> <4DEE3859.6070808@fnarfbargle.com>
	 <4DEE4538.1020404@trash.net>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 07 Jun 2011 20:31:24 +0200
Message-ID: <1307471484.3091.43.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Patrick McHardy <kaber@trash.net>
Cc: Brad Campbell <brad@fnarfbargle.com>, Bart De Schuymer <bdschuym@pandora.be>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org

Le mardi 07 juin 2011 A  17:35 +0200, Patrick McHardy a A(C)crit :

> The main suspects would be NAT and TCPMSS. Did you also try whether
> the crash occurs with only one of these these rules?
> 
> > I've just compiled out CONFIG_BRIDGE_NETFILTER and can no longer access
> > the address the way I was doing it, so that's a no-go for me.
> 
> That's really weird since you're apparently not using any bridge
> netfilter features. It shouldn't have any effect besides changing
> at which point ip_tables is invoked. How are your network devices
> configured (specifically any bridges)?

Something in the kernel does 

u16 *ptr = addr (given by kmalloc())

ptr[-1] = 0;

Could be an off-one error in a memmove()/memcopy() or loop...

I cant see a network issue here.

I checked arch/x86/lib/memmove_64.S and it seems fine.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
