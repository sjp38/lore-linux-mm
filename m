Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id CDD086B0089
	for <linux-mm@kvack.org>; Mon, 22 Nov 2010 10:48:45 -0500 (EST)
Received: by gwj18 with SMTP id 18so1327668gwj.8
        for <linux-mm@kvack.org>; Mon, 22 Nov 2010 07:48:41 -0800 (PST)
Date: Mon, 22 Nov 2010 23:51:52 +0800
From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: [5/8,v3] NUMA Hotplug Emulator: support cpu probe/release in
	x86
Message-ID: <20101122155151.GD4137@hack>
References: <20101117020759.016741414@intel.com> <20101117021000.776651300@intel.com> <20101121144511.GJ9099@hack> <20101122000104.GA7986@shaohui>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20101122000104.GA7986@shaohui>
Sender: owner-linux-mm@kvack.org
To: Shaohui Zheng <shaohui.zheng@intel.com>
Cc: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, haicheng.li@linux.intel.com, lethal@linux-sh.org, ak@linux.intel.com, shaohui.zheng@linux.intel.com, Ingo Molnar <mingo@elte.hu>, Len Brown <len.brown@intel.com>, Yinghai Lu <Yinghai.Lu@Sun.COM>, Haicheng Li <haicheng.li@intel.com>
List-ID: <linux-mm.kvack.org>

On Mon, Nov 22, 2010 at 08:01:04AM +0800, Shaohui Zheng wrote:
>On Sun, Nov 21, 2010 at 10:45:11PM +0800, AmA(C)rico Wang wrote:
>> On Wed, Nov 17, 2010 at 10:08:04AM +0800, shaohui.zheng@intel.com wrote:
>> >From: Shaohui Zheng <shaohui.zheng@intel.com>
>> >
>> >Add cpu interface probe/release under sysfs for x86. User can use this
>> >interface to emulate the cpu hot-add process, it is for cpu hotplug 
>> >test purpose. Add a kernel option CONFIG_ARCH_CPU_PROBE_RELEASE for this
>> >feature.
>> >
>> >This interface provides a mechanism to emulate cpu hotplug with software
>> > methods, it becomes possible to do cpu hotplug automation and stress
>> >testing.
>> >
>> 
>> Huh? We already have CPU online/offline...
>> 
>> Can you describe more about the difference?
>> 
>> Thanks.
>
>Again, we already try to discribe the difference between logcial cpu
>online/offline and physical cpu online/offline many times.
>

I see, with "maxcpus=" we will only have the specified number
of CPU's which can be online/offline, you are trying to bring
the rest of CPU's hidden by "maxcpus=". :) Correct?

I think the idea is cool, but I think you need to improve
the documetion, for people who don't follow the hardware
concepts like me. ;)

Thanks.

-- 
Live like a child, think like the god.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
