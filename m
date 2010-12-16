Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 819806B0098
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 19:59:33 -0500 (EST)
Date: Fri, 17 Dec 2010 07:34:35 +0800
From: Shaohui Zheng <shaohui.zheng@linux.intel.com>
Subject: Re: [5/7, v9] NUMA Hotplug Emulator: Support cpu probe/release in
 x86_64
Message-ID: <20101216233435.GA26886@shaohui>
References: <20101210073119.156388875@intel.com>
 <20101210073242.670777298@intel.com>
 <20101216162541.GA14157@mgebm.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101216162541.GA14157@mgebm.net>
Sender: owner-linux-mm@kvack.org
To: Eric B Munson <emunson@mgebm.net>
Cc: shaohui.zheng@intel.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, rientjes@google.com, dave@linux.vnet.ibm.com, gregkh@suse.de, Ingo Molnar <mingo@elte.hu>, Len Brown <len.brown@intel.com>, Yinghai Lu <Yinghai.Lu@Sun.COM>, Tejun Heo <tj@kernel.org>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 16, 2010 at 09:25:41AM -0700, Eric B Munson wrote:
> Shaohui,
> 
> What kernel is this series based on?  I cannot get it to build when applied
> to mainline.  I seem to be missing a definition for set_apicid_to_node.
> 
> Eric
> 

Eric,
	These is a code conflict with Tejun's NUNA unification code, and Tejun's code is still under
review. This patchset solves the code conflict, the v9 emulator is based on his patches, and we
need to wait until his patches was accepted.

Tejun's patch: http://marc.info/?l=linux-kernel&m=129087151912379.

	If you are doing some testing, you can try to use v8 emulator.

-- 
Thanks & Regards,
Shaohui

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
