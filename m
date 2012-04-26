Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id DB68D6B004A
	for <linux-mm@kvack.org>; Thu, 26 Apr 2012 12:09:07 -0400 (EDT)
Date: Thu, 26 Apr 2012 17:08:52 +0100
From: Richard Davies <richard.davies@elastichosts.com>
Subject: Re: [RFC][PATCH] avoid swapping out with swappiness==0
Message-ID: <20120426160852.GA12568@alpha.arachsys.com>
References: <20120424082019.GA18395@alpha.arachsys.com>
 <alpine.DEB.2.00.1204260948520.16059@router.home>
 <4F996BA6.9010900@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F996BA6.9010900@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Satoru Moriya <satoru.moriya@hds.com>, Jerome Marchand <jmarchan@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "riel@redhat.com" <riel@redhat.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "shaohua.li@intel.com" <shaohua.li@intel.com>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Seiji Aguchi <seiji.aguchi@hds.com>, Minchan Kim <minchan.kim@gmail.com>

KOSAKI Motohiro wrote:
> Christoph Lameter wrote:
> > Richard Davies wrote:
> >
> > > I strongly believe that Linux should have a way to turn off swapping unless
> > > absolutely necessary. This means that users like us can run with swap
> > > present for emergency use, rather than having to disable it because of the
> > > side effects.
> >
> > Agree. And this ooperation mode should be the default behavior given that
> > swapping is a very slow and tedious process these days.
> 
> Even though current patch is not optimal, I don't disagree this opinion. Can
> you please explain your use case? Why don't you use swapoff?

My use case is that I have large (64 or 128GB RAM) qemu-kvm virtualization
hosts, running many (20-50) VMs.

Typically the total memory in use is less than physical memory. In these
cases I would like the virtualization host to run without any swapping. I
have set swappiness==0, but in practise I get big load spikes from swapping.
See http://marc.info/?l=linux-mm&m=133517452117581

I don't want to run swapoff, because sometimes I will need to provision
slightly more VMs than physical memory, and in these cases I would rather
that the system runs with a little swap in use rather than the OOM killer
occurring.

Richard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
