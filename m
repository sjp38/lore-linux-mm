Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 913326B0031
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 05:16:56 -0400 (EDT)
Message-ID: <51C41AB4.9070500@cn.fujitsu.com>
Date: Fri, 21 Jun 2013 17:19:48 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [Part1 PATCH v5 00/22] x86, ACPI, numa: Parse numa info earlier
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com> <20130618020357.GZ32663@mtj.dyndns.org> <51BFF464.809@cn.fujitsu.com> <20130618172129.GH2767@htj.dyndns.org> <51C298B2.9060900@cn.fujitsu.com> <20130620061719.GA16114@mtj.dyndns.org>
In-Reply-To: <20130620061719.GA16114@mtj.dyndns.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: yinghai@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hi tj,

On 06/20/2013 02:17 PM, Tejun Heo wrote:
......
>
> I was suggesting two separate things.
>
> * As memblock allocator can relocate itself.  There's no point in
>    avoiding setting NUMA node while parsing and registering NUMA
>    topology.  Just parse and register NUMA info and later tell it to
>    relocate itself out of hot-pluggable node.  A number of patches in
>    the series is doing this dancing - carefully reordering NUMA
>    probing.  No need to do that.  It's really fragile thing to do.
>
> * Once you get the above out of the way, I don't think there are a lot
>    of permanent allocations in the way before NUMA is initialized.
>    Re-order the remaining ones if that's cleaner to do.  If that gets
>    overly messy / fragile, copying them around or freeing and reloading
>    afterwards could be an option too.

memblock allocator can relocate itself, but it cannot relocate the memory
it allocated for users. There could be some pointers pointing to these
memory ranges. If we do the relocation, how to update these pointers ?

Or, do you mean modify the pagetable ?  I don't think so.

So would you please tell me more about how to do the relocation ?

Thanks. :)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
