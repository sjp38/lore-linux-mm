From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-mm] Add an owner to the mm_struct (v8)
Date: Mon, 7 Apr 2008 19:55:49 -0700
Message-ID: <20080407195549.beca617e.akpm@linux-foundation.org>
References: <20080404080544.26313.38199.sendpatchset@localhost.localdomain>
	<20080407150956.9a29573a.akpm@linux-foundation.org>
	<47FADAFD.7030202@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755991AbYDHC4f@vger.kernel.org>
In-Reply-To: <47FADAFD.7030202@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: balbir@linux.vnet.ibm.com
Cc: menage@google.com, xemul@openvz.org, hugh@veritas.com, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, rientjes@google.com, kamezawa.hiroyu@jp.fujitsu.com
List-Id: linux-mm.kvack.org

On Tue, 08 Apr 2008 08:09:57 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> Andrew Morton wrote:
> > On Fri, 04 Apr 2008 13:35:44 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> >> 1. Add mm->owner change callbacks using cgroups
> >>
> >> ...
> >>
> >> +config MM_OWNER
> >> +	bool "Enable ownership of mm structure"
> >> +	help
> >> +	  This option enables mm_struct's to have an owner. The advantage
> >> +	  of this approach is that it allows for several independent memory
> >> +	  based cgroup controllers to co-exist independently without too
> >> +	  much space overhead
> >> +
> >> +	  This feature adds fork/exit overhead. So enable this only if
> >> +	  you need resource controllers
> > 
> > Do we really want to offer this option to people?  It's rather a low-level
> > thing and it's likely to cause more confusion than it's worth.  Remember
> > that most kernels get to our users via kernel vendors - to what will they
> > be setting this config option?
> > 
> 
> I suspect that this kernel option will not be explicitly set it. This option
> will be selected by other config options (memory controller, swap namespace,
> revoke*)

I believe that the way to do this is to not give the option a `help'
section.  Tht makes it a Kconfig-internal-only thing.
