Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 60BEC6B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 08:40:54 -0400 (EDT)
Date: Fri, 10 Jun 2011 13:40:34 +0100
From: Tim Deegan <Tim.Deegan@citrix.com>
Subject: Re: [Xen-devel] Possible shadow bug
Message-ID: <20110610124034.GI5098@whitby.uk.xensource.com>
References: <BANLkTinMamg_qesEffGxKu3QkT=zyQ2MRQ@mail.gmail.com>
 <4DEE26E7.2060201@redhat.com>
 <20110608123527.479e6991.kamezawa.hiroyu@jp.fujitsu.com>
 <4DF0801F.9050908@redhat.com>
 <alpine.DEB.2.00.1106091311530.12963@kaball-desktop>
 <20110609150133.GF5098@whitby.uk.xensource.com>
 <4DF0F90D.4010900@redhat.com>
 <20110610100139.GG5098@whitby.uk.xensource.com>
 <20110610101011.GH5098@whitby.uk.xensource.com>
 <20110610114821.GB32595@reaktio.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Disposition: inline
In-Reply-To: <20110610114821.GB32595@reaktio.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasi K?rkk?inen <pasik@iki.fi>
Cc: xen-devel@lists.xensource.com, Keir Fraser <keir@xen.org>, Stabellini <stefano.stabellini@eu.citrix.com>, "containers@lists.linux-foundation.org" <containers@lists.linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Keir Fraser <keir.xen@gmail.com>, Igor Mammedov <imammedo@redhat.com>, Paul Menage <menage@google.com>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>

At 14:48 +0300 on 10 Jun (1307717301), Pasi K?rkk?inen wrote:
> On Fri, Jun 10, 2011 at 11:10:11AM +0100, Tim Deegan wrote:
> > At 11:01 +0100 on 10 Jun (1307703699), Tim Deegan wrote:
> > > ISTR that even though the RHEL xen reports a 3.0.x version it has quite
> > > a lot of backports in it.  Does it have this patch?
> > > http://hg.uk.xensource.com/xen-3.1-testing.hg/rev/e8fca4c42d05
> > 
> > Oops, that URL doesn't work; I meant this:
> > http://xenbits.xen.org/xen-3.1-testing.hg/rev/e8fca4c42d05
> > 
> 
> RHEL5 Xen (hypervisor) reports version as 3.1.2-xyz..

Based on a quick scrobble through the CentOS 5.6 SRPMs it looks like a
3.1.0 hypervisor with a bunch of extra patches, but not this one.  This
is very likely the cause of the crash in mem_cgroup_create(), and
probably the corruptions too.  That would explain why they didn't happen
on a 4.0.x SLES11 Xen, but not really why the original patch in this
thread made it go away.

Cheers,

Tim.

-- 
Tim Deegan <Tim.Deegan@citrix.com>
Principal Software Engineer, Xen Platform Team
Citrix Systems UK Ltd.  (Company #02937203, SL9 0BG)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
