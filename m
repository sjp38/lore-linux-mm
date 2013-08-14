Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id A238F6B0033
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 17:36:42 -0400 (EDT)
Received: by mail-qe0-f54.google.com with SMTP id i11so235497qej.41
        for <linux-mm@kvack.org>; Wed, 14 Aug 2013 14:36:41 -0700 (PDT)
Date: Wed, 14 Aug 2013 17:36:37 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH part5 0/7] Arrange hotpluggable memory as ZONE_MOVABLE.
Message-ID: <20130814213637.GO28628@htj.dyndns.org>
References: <20130812162247.GM15892@htj.dyndns.org>
 <520914D5.7080501@gmail.com>
 <20130812180758.GA8288@mtj.dyndns.org>
 <520BC950.1030806@gmail.com>
 <20130814182342.GG28628@htj.dyndns.org>
 <520BDD2F.2060909@gmail.com>
 <20130814195541.GH28628@htj.dyndns.org>
 <520BE891.8090004@gmail.com>
 <20130814203538.GK28628@htj.dyndns.org>
 <520BF3E3.5030006@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <520BF3E3.5030006@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Cc: Tang Chen <imtangchen@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Wed, Aug 14, 2013 at 05:17:23PM -0400, KOSAKI Motohiro wrote:
> You haven't explain practical benefit of your opinion. As far as users have
> no benefit, I'm never agree. Sorry.

Umm... how about being more robust and actually useable to begin with?
What's the benefit of panicking?  Are you seriously saying that the
admin / boot script can use the kernel boot param to tell the kernel
to enable hotplug but can't check what nodes are hot unpluggable
afterwards?  The admin *needs* to check which nodes are hotpluggable
no matter how this part is handled.  How else is it gonna know which
nodes are hotpluggable?  Magic?

There's no such rule as kernel param should make the kernel panic if
it's not happy, so please take that out of your brain.  It of course
should be clear what the result of the kernel parameter is and
panicking is the crudest way to do that which is good enough or even
desriable in *some* cases.  It is not the required behavior by any
stretch of imgination, especially when the result of the parameter may
change due to changing circumstances.  That's an outright idiotic
thing to do.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
