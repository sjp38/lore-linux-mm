Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 3E0D36B0038
	for <linux-mm@kvack.org>; Sat, 26 Sep 2015 05:42:03 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so130615158pac.2
        for <linux-mm@kvack.org>; Sat, 26 Sep 2015 02:42:03 -0700 (PDT)
Received: from heian.cn.fujitsu.com ([59.151.112.132])
        by mx.google.com with ESMTP id sx6si11507629pbc.55.2015.09.26.02.37.36
        for <linux-mm@kvack.org>;
        Sat, 26 Sep 2015 02:42:02 -0700 (PDT)
Message-ID: <560666EA.7090109@cn.fujitsu.com>
Date: Sat, 26 Sep 2015 17:35:38 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 3/7] x86, gfp: Cache best near node for memory allocation.
References: <1441859269-25831-1-git-send-email-tangchen@cn.fujitsu.com> <1441859269-25831-4-git-send-email-tangchen@cn.fujitsu.com> <20150910192935.GI8114@mtj.duckdns.org> <20150910193819.GJ8114@mtj.duckdns.org> <alpine.DEB.2.11.1509101908410.11150@east.gentwo.org>
In-Reply-To: <alpine.DEB.2.11.1509101908410.11150@east.gentwo.org>
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Tejun Heo <tj@kernel.org>
Cc: jiang.liu@linux.intel.com, mika.j.penttila@gmail.com, mingo@redhat.com, akpm@linux-foundation.org, rjw@rjwysocki.net, hpa@zytor.com, yasu.isimatu@gmail.com, isimatu.yasuaki@jp.fujitsu.com, kamezawa.hiroyu@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, gongzhaogang@inspur.com, qiaonuohan@cn.fujitsu.com, x86@kernel.org, linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Gu Zheng <guz.fnst@cn.fujitsu.com>

Hi, Christoph, tj,

On 09/11/2015 08:14 AM, Christoph Lameter wrote:
> On Thu, 10 Sep 2015, Tejun Heo wrote:
>
>>> Why not just update node_data[]->node_zonelist in the first place?
>>> Also, what's the synchronization rule here?  How are allocators
>>> synchronized against node hot [un]plugs?
>> Also, shouldn't kmalloc_node() or any public allocator fall back
>> automatically to a near node w/o GFP_THISNODE?  Why is this failing at
>> all?  I get that cpu id -> node id mapping changing messes up the
>> locality but allocations shouldn't fail, right?

Yes. That is the reason we are getting near online node here.

> Yes that should occur in the absence of other constraints (mempolicies,
> cpusets, cgroups, allocation type). If the constraints do not allow an
> allocation then the allocation will fail.
>
> Also: Are the zonelists setup the right way?

zonelist will be rebuilt in __offline_pages() when the zone is not 
populated any more.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
