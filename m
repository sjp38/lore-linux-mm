Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id D05B56B0055
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 17:40:53 -0400 (EDT)
Date: Wed, 16 Sep 2009 00:38:54 +0300
From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCHv5 3/3] vhost_net: a kernel-level virtio server
Message-ID: <20090915213854.GE27954@redhat.com>
References: <4AAF8A03.5020806@redhat.com> <4AAF909F.9080306@gmail.com> <4AAF95D1.1080600@redhat.com> <4AAF9BAF.3030109@gmail.com> <4AAFACB5.9050808@redhat.com> <4AAFF437.7060100@gmail.com> <20090915204036.GA27954@redhat.com> <4AAFFC8E.9010404@gmail.com> <20090915212545.GC27954@redhat.com> <4AB0098F.9030207@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4AB0098F.9030207@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Gregory Haskins <gregory.haskins@gmail.com>
Cc: Avi Kivity <avi@redhat.com>, "Ira W. Snyder" <iws@ovro.caltech.edu>, netdev@vger.kernel.org, virtualization@lists.linux-foundation.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, mingo@elte.hu, linux-mm@kvack.org, akpm@linux-foundation.org, hpa@zytor.com, Rusty Russell <rusty@rustcorp.com.au>, s.hetze@linux-ag.com, alacrityvm-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

On Tue, Sep 15, 2009 at 05:39:27PM -0400, Gregory Haskins wrote:
> Michael S. Tsirkin wrote:
> > On Tue, Sep 15, 2009 at 04:43:58PM -0400, Gregory Haskins wrote:
> >> Michael S. Tsirkin wrote:
> >>> On Tue, Sep 15, 2009 at 04:08:23PM -0400, Gregory Haskins wrote:
> >>>> No, what I mean is how do you surface multiple ethernet and consoles to
> >>>> the guests?  For Ira's case, I think he needs at minimum at least one of
> >>>> each, and he mentioned possibly having two unique ethernets at one point.
> >>>>
> >>>> His slave boards surface themselves as PCI devices to the x86
> >>>> host.  So how do you use that to make multiple vhost-based devices (say
> >>>> two virtio-nets, and a virtio-console) communicate across the transport?
> >>>>
> >>>> There are multiple ways to do this, but what I am saying is that
> >>>> whatever is conceived will start to look eerily like a vbus-connector,
> >>>> since this is one of its primary purposes ;)
> >>> Can't all this be in userspace?
> >> Can you outline your proposal?
> >>
> >> -Greg
> >>
> > 
> > Userspace in x86 maps a PCI region, uses it for communication with ppc?
> > 
> 
> And what do you propose this communication to look like?

Who cares? Implement vbus protocol there if you like.

> -Greg
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
