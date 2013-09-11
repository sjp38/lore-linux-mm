Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id A347B6B0031
	for <linux-mm@kvack.org>; Wed, 11 Sep 2013 08:51:06 -0400 (EDT)
Received: by mail-yh0-f50.google.com with SMTP id a41so3486912yho.37
        for <linux-mm@kvack.org>; Wed, 11 Sep 2013 05:51:05 -0700 (PDT)
Date: Wed, 11 Sep 2013 08:51:01 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2 0/9] x86, memblock: Allocate memory near kernel image
 before SRAT parsed.
Message-ID: <20130911125101.GA20997@htj.dyndns.org>
References: <1378894057-30946-1-git-send-email-tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1378894057-30946-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, toshi.kani@hp.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Wed, Sep 11, 2013 at 06:07:28PM +0800, Tang Chen wrote:
> This patch-set is based on tj's suggestion, and not fully tested. 
> Just for review and discussion. And according to tj's suggestion, 
> implemented a new function memblock_alloc_bottom_up() to allocate 
> memory from bottom upwards, whihc can simplify the code.

For $DEITY's sake, can you please specify against which tree the
patches are?  :(

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
