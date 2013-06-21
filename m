Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id F35496B0034
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 02:26:36 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz11so7386177pad.30
        for <linux-mm@kvack.org>; Thu, 20 Jun 2013 23:26:36 -0700 (PDT)
Date: Thu, 20 Jun 2013 23:26:31 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [Part1 PATCH v5 00/22] x86, ACPI, numa: Parse numa info earlier
Message-ID: <20130621062631.GA11014@mtj.dyndns.org>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
 <51C3E276.8030804@zytor.com>
 <51C3ED76.3040900@cn.fujitsu.com>
 <51C3EE54.4060707@zytor.com>
 <51C3F0AC.5020006@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51C3F0AC.5020006@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, tglx@linutronix.de, mingo@elte.hu, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Toshi Kani <toshi.kani@hp.com>

Hello, guys.

On Fri, Jun 21, 2013 at 02:20:28PM +0800, Tang Chen wrote:
> >What about Tejun's feedback?
> 
> tj's comments were after the latest version. So we need to
> restructure the patch-set.

Given that it's unlikely to reach actual functionality in this cycle,
it's probably a better idea to aim the next cycle.  I don't think we
wanna rush it.  As for my suggestions, I'm not sure how much of it'd
work out and how much better it's gonna make things but it definitely
seems worth investigating to me.  Let's please see how it goes.

Thanks a lot!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
