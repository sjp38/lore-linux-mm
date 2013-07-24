Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 311B26B0033
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 12:03:50 -0400 (EDT)
Received: by mail-gg0-f170.google.com with SMTP id s5so84892ggc.29
        for <linux-mm@kvack.org>; Wed, 24 Jul 2013 09:03:48 -0700 (PDT)
Date: Wed, 24 Jul 2013 12:03:42 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 11/21] x86: get pg_data_t's memory from other node
Message-ID: <20130724160342.GC20377@mtj.dyndns.org>
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
 <1374220774-29974-12-git-send-email-tangchen@cn.fujitsu.com>
 <20130723200924.GP21100@mtj.dyndns.org>
 <51EF4F95.1050308@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51EF4F95.1050308@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hello, Tang.

On Wed, Jul 24, 2013 at 11:52:53AM +0800, Tang Chen wrote:
> The node data should be on local, I agree with that. I'm not saying I
> won't do it. Just for now, it will be complicated to fix memory hot-remove
> path. So I think pushing this patch for now, and do the local node things
> in the next step.

I see.  As long as it's clearly noted in the patch description and as
comment && the behavior is off unless explicitly enabled, it should be
fine for now, I think.  As currently implemented, the users of memory
hotplug would have to pay pretty heavy price in terms of memory
locality overhead in general and it could be that the ones missed here
might not make noticeable difference anyway.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
