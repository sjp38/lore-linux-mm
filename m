Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id BA6866B0033
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 11:55:05 -0400 (EDT)
Received: by mail-yh0-f48.google.com with SMTP id b20so179196yha.21
        for <linux-mm@kvack.org>; Wed, 24 Jul 2013 08:55:04 -0700 (PDT)
Date: Wed, 24 Jul 2013 11:54:58 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 02/21] memblock, numa: Introduce flag into memblock.
Message-ID: <20130724155458.GA20377@mtj.dyndns.org>
References: <1374220774-29974-1-git-send-email-tangchen@cn.fujitsu.com>
 <1374220774-29974-3-git-send-email-tangchen@cn.fujitsu.com>
 <20130723190928.GH21100@mtj.dyndns.org>
 <51EF4196.8050303@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51EF4196.8050303@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Wed, Jul 24, 2013 at 10:53:10AM +0800, Tang Chen wrote:
> >Let's please drop "with" and do we really need to print full 16
> >digits?
> 
> Sure, will remove "with". But I think printing out the full flags is batter.
> The output seems more tidy.

I mean, padding is fine but you can just print out 4 or even 2 digits
and will be fine for the foreseeable future.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
