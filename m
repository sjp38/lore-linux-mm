Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 151286B0033
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 16:55:02 -0400 (EDT)
Received: by mail-qc0-f174.google.com with SMTP id c1so3659403qcz.19
        for <linux-mm@kvack.org>; Mon, 12 Aug 2013 13:55:02 -0700 (PDT)
Date: Mon, 12 Aug 2013 16:54:56 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH part5 0/7] Arrange hotpluggable memory as ZONE_MOVABLE.
Message-ID: <20130812205456.GC8288@mtj.dyndns.org>
References: <1375956979-31877-1-git-send-email-tangchen@cn.fujitsu.com>
 <20130812145016.GI15892@htj.dyndns.org>
 <5208FBBC.2080304@zytor.com>
 <20130812152343.GK15892@htj.dyndns.org>
 <52090D7F.6060600@gmail.com>
 <20130812164650.GN15892@htj.dyndns.org>
 <52092811.3020105@gmail.com>
 <20130812202029.GB8288@mtj.dyndns.org>
 <3908561D78D1C84285E8C5FCA982C28F31CB74A1@ORSMSX106.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F31CB74A1@ORSMSX106.amr.corp.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: Tang Chen <imtangchen@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Tang Chen <tangchen@cn.fujitsu.com>, "Moore, Robert" <robert.moore@intel.com>, "Zheng, Lv" <lv.zheng@intel.com>, "rjw@sisk.pl" <rjw@sisk.pl>, "lenb@kernel.org" <lenb@kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "trenn@suse.de" <trenn@suse.de>, "yinghai@kernel.org" <yinghai@kernel.org>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "izumi.taku@jp.fujitsu.com" <izumi.taku@jp.fujitsu.com>, "mgorman@suse.de" <mgorman@suse.de>, "minchan@kernel.org" <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "vasilis.liaskovitis@profitbricks.com" <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "prarit@redhat.com" <prarit@redhat.com>, "zhangyanfei@cn.fujitsu.com" <zhangyanfei@cn.fujitsu.com>, "yanghy@cn.fujitsu.com" <yanghy@cn.fujitsu.com>, "x86@kernel.org" <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>

Hello, Tony.

On Mon, Aug 12, 2013 at 08:49:42PM +0000, Luck, Tony wrote:
> The only fly I see in the ointment here is the crazy fragmentation of physical
> memory below 4G on X86 systems.  Typically it will all be on the same node.
> But I don't know if there is any specification that requires it be that way. If some
> "helpful" OEM decided to make some "lowmem" (below 4G) be available on
> every node, they might in theory do something truly awesomely strange.  But
> even here - the granularity of such mappings tends to be large enough that
> the "allocate near where the kernel was loaded" should still work to make those
> allocations be on the same node for the "few megabytes" level of allocations.

Yeah, "near kernel" allocations are needed only till SRAT information
is parsed and fed into memblock.  From then on, it'll be the usual
node-affine top-down allocations, so the memory amount of interest
here is inherently tiny; otherwise, we're doing something silly in our
boot sequence.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
