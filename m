Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 618FD6B0071
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 03:47:16 -0400 (EDT)
Date: Thu, 15 Aug 2013 09:47:14 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] mm: memcontrol: fix handling of swapaccount parameter
Message-ID: <20130815074714.GA27864@dhcp22.suse.cz>
References: <1376486495-21457-1-git-send-email-gergely@risko.hu>
 <20130814183604.GE24033@dhcp22.suse.cz>
 <20130814184956.GF24033@dhcp22.suse.cz>
 <87ioz855o0.fsf@gergely.risko.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87ioz855o0.fsf@gergely.risko.hu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gergely Risko <gergely@risko.hu>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>

[Let's CC Andrew]

On Wed 14-08-13 23:22:23, Gergely Risko wrote:
> On Wed, 14 Aug 2013 20:49:56 +0200, Michal Hocko <mhocko@suse.cz> writes:
> 
> > On Wed 14-08-13 20:36:04, Michal Hocko wrote:
> >> On Wed 14-08-13 15:21:35, Gergely Risko wrote:
> >> > Fixed swap accounting option parsing to enable if called without argument.
> >> 
> >> We used to have [no]swapaccount but that one has been removed by a2c8990a
> >> (memsw: remove noswapaccount kernel parameter) so I do not think that
> >> swapaccount without any given value makes much sense these days.
> >
> > Now that I am reading your changelog again it says this is a fix. Have
> > you experienced any troubles because of the parameter semantic change?
> 
> Yeah, I experienced trouble, I was new to all of this containers +
> cgroups + namespaces thingies and while trying out stuff it was totally
> impossible for me to enable swap accounting and I didn't understand why.
> 
> In Debian swap accounting is off by default, even when you
> cgroup_enable=memory.  So you have to explicitly enable swapaccounting.
> 
> I've found the following documentation snippets all pointing to enable
> swap accounting by just simply adding "swapaccount" to the kernel
> command line.  They all state that "swapaccount" is enough, no need for
> "swapaccount=1" (actually some of them don't even mention =1 at all):
>   - make menuconfig documentation for swap accounting,
>   - /usr/share/doc/lxc/README.Debian from the lxc package,

I've submitted a report with patch
(http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=719774)

>   - Documentation/kernel-parameters.txt:
> 	swapaccount[=0|1]
> 			[KNL] Enable accounting of swap in memory resource
> 			controller if no parameter or 1 is given or disable
> 			it if 0 is given (See Documentation/cgroups/memory.txt),
>   - the comment in the source code just above the line ("consider enabled
>     if no parameter or 1 is given").

Ohh, I have totally missed those left-overs. I would rather fix the doc
than reintroduce the handling without any value.
---
