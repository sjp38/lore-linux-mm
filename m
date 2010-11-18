Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BAB776B0085
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 22:52:25 -0500 (EST)
Date: Thu, 18 Nov 2010 10:31:14 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [8/8,v3] NUMA Hotplug Emulator: documentation
Message-ID: <20101118023114.GB1980@shaohui>
References: <20101117020759.016741414@intel.com>
 <20101117021000.985643862@intel.com>
 <20101117150659.0e0473c7.randy.dunlap@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101117150659.0e0473c7.randy.dunlap@oracle.com>
Sender: owner-linux-mm@kvack.org
To: Randy Dunlap <randy.dunlap@oracle.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 17, 2010 at 03:06:59PM -0800, Randy Dunlap wrote:
> On Wed, 17 Nov 2010 10:08:07 +0800 shaohui.zheng@intel.com wrote:
> 
> > From: Shaohui Zheng <shaohui.zheng@intel.com>
> > 
> > add a text file Documentation/x86/x86_64/numa_hotplug_emulator.txt
> > to explain the usage for the hotplug emulator.
> > 
> > Signed-off-by: Haicheng Li <haicheng.li@intel.com>
> > Signed-off-by: Shaohui Zheng <shaohui.zheng@intel.com>
> > ---
> > Index: linux-hpe4/Documentation/x86/x86_64/numa_hotplug_emulator.txt
> > ===================================================================
> > --- /dev/null	1970-01-01 00:00:00.000000000 +0000
> > +++ linux-hpe4/Documentation/x86/x86_64/numa_hotplug_emulator.txt	2010-11-17 09:01:10.342836513 +0800
> > @@ -0,0 +1,92 @@
> > +NUMA Hotplug Emulator for x86
> 
> (I'm only looking at the documentation file.)
> 
> Is this only for x86_64?  if so, please change the line above (for x86).
> If not, then don't put this file into the /x86_64/ sub-directory.

There are only a few x86_64 specific codes on the patch series, so it should
work for both x86_64 and i386. Currently cpu/memory hotplug works stable against
x86_64 kernel, it still has many issues for i386, so we can not do the testing
for emualtor on i386 kernel, I'd prefer to keep the document for x86_64 only.

> ---
> ~Randy
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
I will check the documentation once again, thanks for the careful review from Randy.

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
