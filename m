Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 1F1B26B007B
	for <linux-mm@kvack.org>; Mon,  6 Jun 2011 16:23:23 -0400 (EDT)
Received: by wwi36 with SMTP id 36so3528891wwi.26
        for <linux-mm@kvack.org>; Mon, 06 Jun 2011 13:23:20 -0700 (PDT)
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
From: Eric Dumazet <eric.dumazet@gmail.com>
In-Reply-To: <4DED344D.7000005@pandora.be>
References: <20110601011527.GN19505@random.random>
	 <alpine.LSU.2.00.1105312120530.22808@sister.anvils>
	 <4DE5DCA8.7070704@fnarfbargle.com> <4DE5E29E.7080009@redhat.com>
	 <4DE60669.9050606@fnarfbargle.com> <4DE60918.3010008@redhat.com>
	 <4DE60940.1070107@redhat.com> <4DE61A2B.7000008@fnarfbargle.com>
	 <20110601111841.GB3956@zip.com.au> <4DE62801.9080804@fnarfbargle.com>
	 <20110601230342.GC3956@zip.com.au> <4DE8E3ED.7080004@fnarfbargle.com>
	 <isavsg$3or$1@dough.gmane.org> <4DE906C0.6060901@fnarfbargle.com>
	 <4DED344D.7000005@pandora.be>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 06 Jun 2011 22:23:17 +0200
Message-ID: <1307391797.2642.12.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart De Schuymer <bdschuym@pandora.be>
Cc: Brad Campbell <brad@fnarfbargle.com>, kvm@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, netfilter-devel@vger.kernel.org

Le lundi 06 juin 2011 A  22:10 +0200, Bart De Schuymer a A(C)crit :
> Hi Brad,
> 
> This has probably nothing to do with ebtables, so please rmmod in case 
> it's loaded.
> A few questions I didn't directly see an answer to in the threads I 
> scanned...
> I'm assuming you actually use the bridging firewall functionality. So, 
> what iptables modules do you use? Can you reduce your iptables rules to 
> a core that triggers the bug?
> Or does it get triggered even with an empty set of firewall rules?
> Are you using a stock .35 kernel or is it patched?
> Is this something I can trigger on a poor guy's laptop or does it 
> require specialized hardware (I'm catching up on qemu/kvm...)?
> 

Keep netdev, as this most probably is a networking bug.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
