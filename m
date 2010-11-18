Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 2796F6B004A
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 22:24:33 -0500 (EST)
Date: Thu, 18 Nov 2010 10:03:21 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [0/8,v3] NUMA Hotplug Emulator - Introduction & Feedbacks
Message-ID: <20101118020321.GA1980@shaohui>
References: <20101117020759.016741414@intel.com>
 <AANLkTinp4A8U61rgODAKyQpauhgTbv4p55utaoVEQR0Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTinp4A8U61rgODAKyQpauhgTbv4p55utaoVEQR0Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Yinghai Lu <yinghai@kernel.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Wed, Nov 17, 2010 at 01:26:59AM -0800, Yinghai Lu wrote:
> On Tue, Nov 16, 2010 at 6:07 PM,  <shaohui.zheng@intel.com> wrote:
> >
> > * WHAT IS HOTPLUG EMULATOR
> >
> > NUMA hotplug emulator is collectively named for the hotplug emulation
> > it is able to emulate NUMA Node Hotplug thru a pure software way. It
> > intends to help people easily debug and test node/cpu/memory hotplug
> > related stuff on a none-numa-hotplug-support machine, even an UMA machine.
> >
> > The emulator provides mechanism to emulate the process of physcial cpu/mem
> > hotadd, it provides possibility to debug CPU and memory hotplug on the machines
> > without NUMA support for kenrel developers. It offers an interface for cpu
> > and memory hotplug test purpose.
> >
> > * WHY DO WE USE HOTPLUG EMULATOR
> >
> > We are focusing on the hotplug emualation for a few months. The emualor helps
> >  team to reproduce all the major hotplug bugs. It plays an important role to
> > the hotplug code quality assuirance. Because of the hotplug emulator, we already
> > move most of the debug working to virtual evironment.
> 
> You should extend kvm to make it support NUMA hotplug guest.
> instead of messing up linux numa code.
Yinghai,
	the purpose of hotplug emulator is for linux cpu/memory hotplug testing, so
it should cover the most linux hotplug linux code path. That is why we select to work
under linux kernel, and it was proved that it is helpful for hotplug debuging in linux
kernel.

	for NUMA hotplug in kvm guest, it is another project.

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
