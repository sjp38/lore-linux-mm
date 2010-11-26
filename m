Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0A5058D0001
	for <linux-mm@kvack.org>; Fri, 26 Nov 2010 01:21:07 -0500 (EST)
Message-Id: <20101126041958.708215617@intel.com>
Date: Fri, 26 Nov 2010 12:19:58 +0800
From: shaohui.zheng@intel.com
Subject: [0/3, v4]  CPU Hotplug Emulatation
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, gregkh@suse.de, linux-mm@kvack.org
Cc: haicheng.li@linux.intel.com, xiyou.wangcong@gmail.com, shaohui.zheng@intel.com, rientjes@google.com
List-ID: <linux-mm.kvack.org>

According to the discussion result on NUMA Hotplug Emulator. There are many
suggestions on node/Memory hotplug emulation, and David Rientjes provides a more
flexiable solution for node/memory hotplug. We appreciate for his patches, 
and we accept his numa=possible=<N> parameters.

For CPU hotplug emulatinon, there are no opposite voices from the community,
and think CPU probe/release is an useful interface.  There is no obvious
relationship with node/memory hotplug, it can work well alone, so I send CPU
hotplug emulation patcheset standalone. it makes the patch reviewing process
faster.

-- 
Thanks & Regards,
Shaohui


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
