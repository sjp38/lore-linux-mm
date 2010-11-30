Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6024C6B004A
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 21:54:36 -0500 (EST)
Date: Tue, 30 Nov 2010 09:31:21 +0800
From: Shaohui Zheng <shaohui.zheng@intel.com>
Subject: Re: [8/8, v5] NUMA Hotplug Emulator: documentation
Message-ID: <20101130013121.GC3021@shaohui>
References: <20101129091750.950277284@intel.com>
 <20101129091936.322099405@intel.com>
 <14037.1291054756@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <14037.1291054756@localhost>
Sender: owner-linux-mm@kvack.org
To: Valdis.Kletnieks@vt.edu
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, rientjes@google.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 29, 2010 at 01:19:16PM -0500, Valdis.Kletnieks@vt.edu wrote:
> On Mon, 29 Nov 2010 17:17:58 +0800, shaohui.zheng@intel.com said:
> > From: Shaohui Zheng <shaohui.zheng@intel.com>
> > 
> > add a text file Documentation/x86/x86_64/numa_hotplug_emulator.txt
> > to explain the usage for the hotplug emulator.
> 
> Can you renumber this to 1/8 if you resubmit it?  It helps code review if you
> already know what it's *intended* to do beforehand.  It also helps drinking
> from the lkml firehose if you can read 0/N and 1/N and know if it's something
> you want to review, otherwise you read 0/N, have to go find N/N, read that,
> then go back and delete 1/N through N-1/N.
> 
> (Sometimes, the 0/N cover isn't enough - reading the documentation actually
> fills in enough blanks to make you go "Wow, this *is* applicable to something
> I'm working on...")

When I send the previous version, I always add the full documentation in 0/N 
patches. The feedbacks, suggestions, and modifications are all included in 0/N 
patch. it makes it as a very long text, so I decide to remove the full documentation
from 0/N since we already send these docs in early version, it get the 0/N patch
 much smaller.

I will still keep the full documentation in 0/N, and renumber 8/8 to 1/8. Thanks
 for the remind.


-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
