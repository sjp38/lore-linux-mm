Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 167B36B0254
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 06:02:54 -0400 (EDT)
Received: by pacfv9 with SMTP id fv9so86967638pac.3
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 03:02:53 -0700 (PDT)
Received: from mgwkm03.jp.fujitsu.com (mgwkm03.jp.fujitsu.com. [202.219.69.170])
        by mx.google.com with ESMTPS id l11si19914221pbq.245.2015.10.22.03.02.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 22 Oct 2015 03:02:53 -0700 (PDT)
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id DEF25AC00D9
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 19:02:44 +0900 (JST)
Subject: Re: [PATCH] mm: Introduce kernelcore=reliable option
References: <1444915942-15281-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <3908561D78D1C84285E8C5FCA982C28F32B5A060@ORSMSX114.amr.corp.intel.com>
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <5628B427.3050403@jp.fujitsu.com>
Date: Thu, 22 Oct 2015 19:02:15 +0900
MIME-Version: 1.0
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F32B5A060@ORSMSX114.amr.corp.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, Taku Izumi <izumi.taku@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: "qiuxishi@huawei.com" <qiuxishi@huawei.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Hansen, Dave" <dave.hansen@intel.com>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>

On 2015/10/22 3:17, Luck, Tony wrote:
> +	if (reliable_kernelcore) {
> +		for_each_memblock(memory, r) {
> +			if (memblock_is_mirror(r))
> +				continue;
>
> Should we have a safety check here that there is some mirrored memory?  If you give
> the kernelcore=reliable option on a machine which doesn't have any mirror configured,
> then we'll mark all memory as removable.

You're right.

> What happens then?  Do kernel allocations fail?  Or do they fall back to using removable memory?

Maybe the kernel cannot boot because NORMAL zone is empty.

> Is there a /proc or /sys file that shows the current counts for the removable zone?  I just
> tried this patch with a high percentage of memory marked as mirror ... but I'd like to see
> how much is actually being used to tune things a bit.
>

I think /proc/zoneinfo can show detailed numbers per zone. Do we need some for meminfo ?

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
