Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 80D436B0254
	for <linux-mm@kvack.org>; Tue, 18 Aug 2015 07:29:48 -0400 (EDT)
Received: by pabyb7 with SMTP id yb7so131046675pab.0
        for <linux-mm@kvack.org>; Tue, 18 Aug 2015 04:29:48 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id s13si29957479pdi.27.2015.08.18.04.29.46
        for <linux-mm@kvack.org>;
        Tue, 18 Aug 2015 04:29:47 -0700 (PDT)
Message-ID: <55D316CB.3010509@cn.fujitsu.com>
Date: Tue, 18 Aug 2015 19:28:11 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Patch V3 9/9] mm, x86: Enable memoryless node support to better
 support CPU/memory hotplug
References: <1439781546-7217-1-git-send-email-jiang.liu@linux.intel.com> <1439781546-7217-10-git-send-email-jiang.liu@linux.intel.com> <55D2CC76.4020100@cn.fujitsu.com> <55D2D7C2.3090109@linux.intel.com>
In-Reply-To: <55D2D7C2.3090109@linux.intel.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiang Liu <jiang.liu@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Mike Galbraith <umgwanakikbuti@gmail.com>, Peter Zijlstra <peterz@infradead.org>, "Rafael J . Wysocki" <rafael.j.wysocki@intel.com>, Tejun Heo <tj@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, Len Brown <len.brown@intel.com>, Pavel Machek <pavel@ucw.cz>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@amacapital.net>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Dave Hansen <dave.hansen@linux.intel.com>, =?windows-1252?Q?=22Jan_H=2E?= =?windows-1252?Q?_Sch=F6nherr=22?= <jschoenh@amazon.de>, Igor Mammedov <imammedo@redhat.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Xishi Qiu <qiuxishi@huawei.com>, Luiz Capitulino <lcapitulino@redhat.com>, Dave Young <dyoung@redhat.com>
Cc: Tony Luck <tony.luck@intel.com>, linux-mm@kvack.org, linux-hotplug@vger.kernel.org, linux-kernel@vger.kernel.org, Ingo Molnar <mingo@kernel.org>, linux-pm@vger.kernel.org, tangchen@cn.fujitsu.com


On 08/18/2015 02:59 PM, Jiang Liu wrote:
>
> ...
>>>        }
>>> @@ -739,6 +746,22 @@ void __init init_cpu_to_node(void)
>>>            if (!node_online(node))
>>>                node = find_near_online_node(node);

Hi Liu,

If cpu-less, memory-less and normal node will all be online anyway,
I think we don't need to find_near_online_node() any more for
CPUs on offline nodes.

Or is there any other case ?

Thanks.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
