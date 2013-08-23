Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 9D6306B0032
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 10:35:12 -0400 (EDT)
Received: by mail-qc0-f181.google.com with SMTP id k15so360522qcv.40
        for <linux-mm@kvack.org>; Fri, 23 Aug 2013 07:35:11 -0700 (PDT)
Date: Fri, 23 Aug 2013 10:35:07 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 0/8] x86, acpi: Move acpi_initrd_override() earlier.
Message-ID: <20130823143507.GB3277@htj.dyndns.org>
References: <20130822183130.GA3490@mtj.dyndns.org>
 <1377202292.10300.693.camel@misato.fc.hp.com>
 <20130822202158.GD3490@mtj.dyndns.org>
 <1377205598.10300.715.camel@misato.fc.hp.com>
 <20130822212111.GF3490@mtj.dyndns.org>
 <1377209861.10300.756.camel@misato.fc.hp.com>
 <20130823130440.GC10322@mtj.dyndns.org>
 <3ee58764-21c2-4df4-9353-54799a6a3d7b@email.android.com>
 <20130823141924.GA3277@htj.dyndns.org>
 <bf688aac-4080-4ac6-83cd-fd66cef6ce1a@email.android.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <bf688aac-4080-4ac6-83cd-fd66cef6ce1a@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Toshi Kani <toshi.kani@hp.com>, Zhang Yanfei <zhangyanfei.yes@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, konrad.wilk@oracle.com, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Hello,

On Fri, Aug 23, 2013 at 04:24:06PM +0200, H. Peter Anvin wrote:
> Well... relying on MTRRs is a big cost in complexity and failure modes.

Yeah, it's true that MTRRs are nasty.  On the other hand, we've been
doing that for over a decade and are still doing it anyway if I'm not
mistaken.  It probably isn't a big difference but it's still a bit sad
that this is likely causing small performance regression out in the
wild.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
