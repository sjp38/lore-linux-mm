Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 89C276B0087
	for <linux-mm@kvack.org>; Sun, 21 Nov 2010 09:42:03 -0500 (EST)
Received: by pzk30 with SMTP id 30so1274577pzk.14
        for <linux-mm@kvack.org>; Sun, 21 Nov 2010 06:42:02 -0800 (PST)
Date: Sun, 21 Nov 2010 22:45:11 +0800
From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: [5/8,v3] NUMA Hotplug Emulator: support cpu probe/release in
	x86
Message-ID: <20101121144511.GJ9099@hack>
References: <20101117020759.016741414@intel.com> <20101117021000.776651300@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101117021000.776651300@intel.com>
Sender: owner-linux-mm@kvack.org
To: shaohui.zheng@intel.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Ingo Molnar <mingo@elte.hu>, Len Brown <len.brown@intel.com>, Yinghai Lu <Yinghai.Lu@Sun.COM>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 17, 2010 at 10:08:04AM +0800, shaohui.zheng@intel.com wrote:
>From: Shaohui Zheng <shaohui.zheng@intel.com>
>
>Add cpu interface probe/release under sysfs for x86. User can use this
>interface to emulate the cpu hot-add process, it is for cpu hotplug 
>test purpose. Add a kernel option CONFIG_ARCH_CPU_PROBE_RELEASE for this
>feature.
>
>This interface provides a mechanism to emulate cpu hotplug with software
> methods, it becomes possible to do cpu hotplug automation and stress
>testing.
>

Huh? We already have CPU online/offline...

Can you describe more about the difference?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
