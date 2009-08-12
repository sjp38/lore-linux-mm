Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 97A1E6B004F
	for <linux-mm@kvack.org>; Wed, 12 Aug 2009 08:53:22 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCHv2 0/2] vhost: a kernel-level virtio server
Date: Wed, 12 Aug 2009 14:52:01 +0200
References: <20090811212743.GA26309@redhat.com> <20090812120541.GA29158@redhat.com> <4A82B87B.4010208@gmail.com>
In-Reply-To: <4A82B87B.4010208@gmail.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Message-Id: <200908121452.01802.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Cc: "Michael S. Tsirkin" <mst@redhat.com>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, hpa@zytor.com, Patrick Mullaney <pmullaney@novell.com>
List-ID: <linux-mm.kvack.org>

On Wednesday 12 August 2009, Gregory Haskins wrote:
> >> Are you saying SRIOV is a requirement, and I can either program the
> >> SRIOV adapter with a mac or use promis?  Or are you saying I can use
> >> SRIOV+programmed mac OR a regular nic + promisc (with a perf penalty).
> > 
> > SRIOV is not a requirement. And you can also use a dedicated
> > nic+programmed mac if you are so inclined.
> 
> Makes sense.  Got it.
> 
> I was going to add guest-to-guest to the test matrix, but I assume that
> is not supported with vhost unless you have something like a VEPA
> enabled bridge?
> 

If I understand it correctly, you can at least connect a veth pair
to a bridge, right? Something like

           veth0 - veth1 - vhost - guest 1 
eth0 - br0-|
           veth2 - veth3 - vhost - guest 2
          
It's a bit more complicated than it need to be, but should work fine.

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
