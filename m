Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 4926D6B0095
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 20:12:30 -0500 (EST)
Date: Thu, 2 Dec 2010 07:48:39 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [2/8, v6] NUMA Hotplug Emulator: Add numa=possible option
Message-ID: <20101201234839.GB13509@shaohui>
References: <20101130071324.908098411@intel.com>
 <20101130071436.836186525@intel.com>
 <alpine.DEB.2.00.1012011705280.6088@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1012011705280.6088@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 01, 2010 at 05:06:02PM -0800, David Rientjes wrote:
> On Tue, 30 Nov 2010, shaohui.zheng@intel.com wrote:
> 
> > From:  David Rientjes <rientjes@google.com>
> > 
> > Adds a numa=possible=<N> command line option to set an additional N nodes
> > as being possible for memory hotplug.  This set of possible nodes
> > controls nr_node_ids and the sizes of several dynamically allocated node
> > arrays.
> > 
> > This allows memory hotplug to create new nodes for newly added memory
> > rather than binding it to existing nodes.
> > 
> > The first use-case for this will be node hotplug emulation which will use
> > these possible nodes to create new nodes to test the memory hotplug
> > callbacks and surrounding memory hotplug code.
> > 
> > CC: Shaohui Zheng <shaohui.zheng@intel.com>
> > CC: Haicheng Li <haicheng.li@intel.com>
> > Signed-off-by: David Rientjes <rientjes@google.com>
> 
> You're going to need to add your Signed-off-by line immediately after mine 
> if you're pushing these to a maintainer, you're along the submission 
> chain.

I did not add my name as Signed-off-by since you are the patch author, I will
add it, thanks David.

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
