Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 0F95C6B004A
	for <linux-mm@kvack.org>; Fri, 10 Jun 2011 07:48:29 -0400 (EDT)
Date: Fri, 10 Jun 2011 14:48:21 +0300
From: Pasi =?iso-8859-1?Q?K=E4rkk=E4inen?= <pasik@iki.fi>
Subject: Re: [Xen-devel] Possible shadow bug
Message-ID: <20110610114821.GB32595@reaktio.net>
References: <4DE8D50F.1090406@redhat.com> <BANLkTinMamg_qesEffGxKu3QkT=zyQ2MRQ@mail.gmail.com> <4DEE26E7.2060201@redhat.com> <20110608123527.479e6991.kamezawa.hiroyu@jp.fujitsu.com> <4DF0801F.9050908@redhat.com> <alpine.DEB.2.00.1106091311530.12963@kaball-desktop> <20110609150133.GF5098@whitby.uk.xensource.com> <4DF0F90D.4010900@redhat.com> <20110610100139.GG5098@whitby.uk.xensource.com> <20110610101011.GH5098@whitby.uk.xensource.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110610101011.GH5098@whitby.uk.xensource.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Deegan <Tim.Deegan@citrix.com>
Cc: Igor Mammedov <imammedo@redhat.com>, Stefano@phlegethon.org, Paul Menage <menage@google.com>, xen-devel@lists.xensource.com, Keir Fraser <keir@xen.org>, Stabellini <stefano.stabellini@eu.citrix.com>, "containers@lists.linux-foundation.org" <containers@lists.linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Keir Fraser <keir.xen@gmail.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, KAMEZAWA@phlegethon.org, Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hiroyuki Kamezawa <kamezawa.hiroyuki@gmail.com>

On Fri, Jun 10, 2011 at 11:10:11AM +0100, Tim Deegan wrote:
> At 11:01 +0100 on 10 Jun (1307703699), Tim Deegan wrote:
> > Actually, looking at the disassembly you posted, it looks more like it
> > might be an emulator bug in Xen; if Xen finds itself emulating the IMUL
> > instruction and either gets the logic wrong or does the memory access
> > wrong, it could cause that failure.  And one reason that Xen emulates
> > instructions is if the memory operand is on a pagetable that's shadowed
> > (which might be a page that was recently a pagetable). 
> > 
> > ISTR that even though the RHEL xen reports a 3.0.x version it has quite
> > a lot of backports in it.  Does it have this patch?
> > http://hg.uk.xensource.com/xen-3.1-testing.hg/rev/e8fca4c42d05
> 
> Oops, that URL doesn't work; I meant this:
> http://xenbits.xen.org/xen-3.1-testing.hg/rev/e8fca4c42d05
> 

RHEL5 Xen (hypervisor) reports version as 3.1.2-xyz..

-- Pasi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
