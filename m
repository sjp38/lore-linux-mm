Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id F0F666B0031
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 09:58:20 -0400 (EDT)
Received: by mail-yh0-f44.google.com with SMTP id f64so1234302yha.3
        for <linux-mm@kvack.org>; Mon, 09 Sep 2013 06:58:20 -0700 (PDT)
Date: Mon, 9 Sep 2013 09:58:15 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 00/11] x86, memblock: Allocate memory near kernel image
 before SRAT parsed.
Message-ID: <20130909135815.GB25434@htj.dyndns.org>
References: <1377596268-31552-1-git-send-email-tangchen@cn.fujitsu.com>
 <20130904192215.GG26609@mtj.dyndns.org>
 <52299935.0302450a.26c9.ffffb240SMTPIN_ADDED_BROKEN@mx.google.com>
 <20130906151526.GA22423@mtj.dyndns.org>
 <522db781.22ab440a.41b1.ffffd825SMTPIN_ADDED_BROKEN@mx.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <522db781.22ab440a.41b1.ffffd825SMTPIN_ADDED_BROKEN@mx.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hello,

On Mon, Sep 09, 2013 at 07:56:34PM +0800, Wanpeng Li wrote:
> If allocate from low to high as what this patchset done will occupy the
> precious memory you mentioned?

Yeah, and that'd be the reason why this behavior is dependent on a
kernel option.  That said, allocating some megs on top of kernel isn't
a big deal.  The wretched ISA DMA is mostly gone now and some megs
isn't gonna hurt 32bit DMAs in any noticeable way.  I wouldn't be too
surprised if nobody notices after switching the default behavior to
allocate early mem close to kernel.  Maybe the only case which might
be impacted is 32bit highmem configs, but they're messed up no matter
what anyway and even they shouldn't be affected noticeably if large
mapping is in use.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
