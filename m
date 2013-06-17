Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 2337E6B0032
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 19:08:14 -0400 (EDT)
Received: by mail-pa0-f49.google.com with SMTP id ld11so3295452pab.8
        for <linux-mm@kvack.org>; Mon, 17 Jun 2013 16:08:13 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAE9FiQXTAT69WKvzXe7FuuSqiA9epuSGPFP2ihhpDZkqYtn9_g@mail.gmail.com>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
	<1371128589-8953-4-git-send-email-tangchen@cn.fujitsu.com>
	<20130617210422.GN32663@mtj.dyndns.org>
	<CAE9FiQXTAT69WKvzXe7FuuSqiA9epuSGPFP2ihhpDZkqYtn9_g@mail.gmail.com>
Date: Mon, 17 Jun 2013 16:08:13 -0700
Message-ID: <CAOS58YMuJQ823rrZFHXRdM3bakbzXKq5DWTSkYfYtdV5AZcONQ@mail.gmail.com>
Subject: Re: [Part1 PATCH v5 03/22] x86, ACPI, mm: Kill max_low_pfn_mapped
From: Tejun Heo <tj@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Renninger <trenn@suse.de>, Jiang Liu <jiang.liu@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, mina86@mina86.com, Chen Gong <gong.chen@linux.intel.com>, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, Rik van Riel <riel@redhat.com>, jweiner@redhat.com, Prarit Bhargava <prarit@redhat.com>, the arch/x86 maintainers <x86@kernel.org>, linux-doc@vger.kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, "Rafael J. Wysocki" <rjw@sisk.pl>, Jacob Shin <jacob.shin@amd.com>, Pekka Enberg <penberg@kernel.org>, ACPI Devel Maling List <linux-acpi@vger.kernel.org>

On Mon, Jun 17, 2013 at 2:13 PM, Yinghai Lu <yinghai@kernel.org> wrote:
>> No bigge, but why (1ULL << 32) - 1?  Shouldn't it be just 1ULL << 32?
>> memblock deals with [@start, @end) areas, right?
>
> that is for 32bit, when phys_addr_t is 32bit, in that case
> (1ULL<<32) cast to 32bit would be 0.

Right, it'd work the same even after overflowing but yeah, it can be confusing.

Thanks.

--
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
