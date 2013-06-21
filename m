Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id EA93D6B0031
	for <linux-mm@kvack.org>; Fri, 21 Jun 2013 14:25:15 -0400 (EDT)
Received: by mail-pb0-f47.google.com with SMTP id rr13so8157848pbb.34
        for <linux-mm@kvack.org>; Fri, 21 Jun 2013 11:25:15 -0700 (PDT)
Date: Fri, 21 Jun 2013 11:25:11 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [Part1 PATCH v5 00/22] x86, ACPI, numa: Parse numa info earlier
Message-ID: <20130621182511.GA1763@htj.dyndns.org>
References: <1371128589-8953-1-git-send-email-tangchen@cn.fujitsu.com>
 <20130618020357.GZ32663@mtj.dyndns.org>
 <51BFF464.809@cn.fujitsu.com>
 <20130618172129.GH2767@htj.dyndns.org>
 <51C298B2.9060900@cn.fujitsu.com>
 <20130620061719.GA16114@mtj.dyndns.org>
 <51C41AB4.9070500@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <51C41AB4.9070500@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: yinghai@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Hey,

On Fri, Jun 21, 2013 at 05:19:48PM +0800, Tang Chen wrote:
> >* As memblock allocator can relocate itself.  There's no point in
> >   avoiding setting NUMA node while parsing and registering NUMA
> >   topology.  Just parse and register NUMA info and later tell it to
> >   relocate itself out of hot-pluggable node.  A number of patches in
> >   the series is doing this dancing - carefully reordering NUMA
> >   probing.  No need to do that.  It's really fragile thing to do.
> >
> >* Once you get the above out of the way, I don't think there are a lot
> >   of permanent allocations in the way before NUMA is initialized.
> >   Re-order the remaining ones if that's cleaner to do.  If that gets
> >   overly messy / fragile, copying them around or freeing and reloading
> >   afterwards could be an option too.
> 
> memblock allocator can relocate itself, but it cannot relocate the memory

Hmmm... maybe I wasn't clear but that's the first bullet point above.

> it allocated for users. There could be some pointers pointing to these
> memory ranges. If we do the relocation, how to update these pointers ?

And the second.  Can you please list what persistent areas are
allocated before numa info is configured into memblock?  There
shouldn't be whole lot.  And, again, this type of information should
have been available in the head message so that high-level discussion
could take place right away.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
