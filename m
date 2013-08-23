Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id AB7F66B0034
	for <linux-mm@kvack.org>; Fri, 23 Aug 2013 10:25:58 -0400 (EDT)
In-Reply-To: <20130823141924.GA3277@htj.dyndns.org>
References: <20130822033234.GA2413@htj.dyndns.org> <1377186729.10300.643.camel@misato.fc.hp.com> <20130822183130.GA3490@mtj.dyndns.org> <1377202292.10300.693.camel@misato.fc.hp.com> <20130822202158.GD3490@mtj.dyndns.org> <1377205598.10300.715.camel@misato.fc.hp.com> <20130822212111.GF3490@mtj.dyndns.org> <1377209861.10300.756.camel@misato.fc.hp.com> <20130823130440.GC10322@mtj.dyndns.org> <3ee58764-21c2-4df4-9353-54799a6a3d7b@email.android.com> <20130823141924.GA3277@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH 0/8] x86, acpi: Move acpi_initrd_override() earlier.
From: "H. Peter Anvin" <hpa@zytor.com>
Date: Fri, 23 Aug 2013 16:24:06 +0200
Message-ID: <bf688aac-4080-4ac6-83cd-fd66cef6ce1a@email.android.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Toshi Kani <toshi.kani@hp.com>, Zhang Yanfei <zhangyanfei.yes@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, konrad.wilk@oracle.com, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

Well... relying on MTRRs is a big cost in complexity and failure modes.

Tejun Heo <tj@kernel.org> wrote:
>Hello,
>
>On Fri, Aug 23, 2013 at 03:08:55PM +0200, H. Peter Anvin wrote:
>> What is the point of 1G+MTRR?  If there are caching differences the
>> TLB will fracture the pages anyway.
>
>Ah, right.  Consuming less memory / cachelines would still be a small
>advantage tho unless creating split TLB from larger mapping is
>noticeably less efficient.  If the extra logic to do that is small,
>which I think it'd be, it'd be a gain at almost no cost.
>
>Thanks.

-- 
Sent from my mobile phone. Please excuse brevity and lack of formatting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
