Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id B28BC6B0031
	for <linux-mm@kvack.org>; Mon,  5 Aug 2013 10:52:19 -0400 (EDT)
Received: by mail-qc0-f175.google.com with SMTP id s11so1711478qcv.6
        for <linux-mm@kvack.org>; Mon, 05 Aug 2013 07:52:18 -0700 (PDT)
Date: Mon, 5 Aug 2013 10:52:12 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 RESEND 13/18] x86, numa, mem_hotplug: Skip all the
 regions the kernel resides in.
Message-ID: <20130805145212.GA19631@mtj.dyndns.org>
References: <1375434877-20704-1-git-send-email-tangchen@cn.fujitsu.com>
 <1375434877-20704-14-git-send-email-tangchen@cn.fujitsu.com>
 <51FF44B7.8050704@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51FF44B7.8050704@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Mon, Aug 05, 2013 at 02:22:47PM +0800, Tang Chen wrote:
> I have resent the v2 patch-set. Would you please give some more
> comments about the memblock and x86 booting code modification ?

Patch 13 still seems corrupt.  Is it a problem on my side maybe?
Nope, gmane raw message is corrupt too.

 http://article.gmane.org/gmane.linux.kernel.mm/104549/raw

Can you please verify your mail setup?  It's not very nice to repeat
the same problem.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
