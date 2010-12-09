Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B74666B0088
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 20:58:39 -0500 (EST)
Date: Thu, 9 Dec 2010 08:33:29 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [1/7,v8] NUMA Hotplug Emulator: documentation
Message-ID: <20101209003328.GC5798@shaohui>
References: <20101207010033.280301752@intel.com>
 <20101207010139.681125359@intel.com>
 <20101207182420.GA2038@mgebm.net>
 <20101207232000.GA5353@shaohui>
 <alpine.DEB.2.00.1012081316530.15658@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1012081316530.15658@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Shaohui Zheng <shaohui.zheng@linux.intel.com>, Eric B Munson <emunson@mgebm.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, Andi Kleen <ak@linux.intel.com>, dave@linux.vnet.ibm.com, Greg Kroah-Hartman <gregkh@suse.de>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 08, 2010 at 01:18:02PM -0800, David Rientjes wrote:
> On Wed, 8 Dec 2010, Shaohui Zheng wrote:
> 
> > Eric,
> > 	the major change on the patchset is on the interface, for the v8 emulator,
> > we accept David's per-node debugfs add_memory interface, we already included
> > in the documentation patch. the change is very small, so it is not obvious.
> > 
> 
> It's still stale as Eric mentioned: for instance, the reference to 
> /sys/kernel/debug/node/add_node which is now under mem_hotplug.  There may 
> be other examples as well.

I forget to udpate this part, my carelessness, thanks Eric and David.

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
