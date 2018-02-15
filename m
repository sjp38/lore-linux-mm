Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 855A96B0003
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 08:20:26 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id z2so3890075pgu.18
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 05:20:26 -0800 (PST)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id a15si1127357pgd.21.2018.02.15.05.20.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Feb 2018 05:20:25 -0800 (PST)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w1FDGtCm149791
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:20:23 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by userp2120.oracle.com with ESMTP id 2g58nm0m79-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:20:22 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w1FDKKhL021892
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:20:21 GMT
Received: from abhmp0011.oracle.com (abhmp0011.oracle.com [141.146.116.17])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w1FDKJSk000899
	for <linux-mm@kvack.org>; Thu, 15 Feb 2018 13:20:20 GMT
Received: by mail-ot0-f179.google.com with SMTP id s4so23330182oth.7
        for <linux-mm@kvack.org>; Thu, 15 Feb 2018 05:20:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180215105510.5md37yoqij2f663k@suse.de>
References: <20180214163343.21234-1-pasha.tatashin@oracle.com>
 <20180214163343.21234-2-pasha.tatashin@oracle.com> <20180215105510.5md37yoqij2f663k@suse.de>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Thu, 15 Feb 2018 08:20:18 -0500
Message-ID: <CAOAebxs3Lch0ZQ6h8jSVqHMpLxfUHv-y4rkJztPziFgm2VfH0g@mail.gmail.com>
Subject: Re: [PATCH v4 1/1] mm: initialize pages on demand during boot
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Steve Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, m.mizuma@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, baiyaowei@cmss.chinamobile.com, Wei Yang <richard.weiyang@gmail.com>, Paul Burton <paul.burton@mips.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

Thank you Mel!

Pavel

On Thu, Feb 15, 2018 at 5:55 AM, Mel Gorman <mgorman@suse.de> wrote:
> On Wed, Feb 14, 2018 at 11:33:43AM -0500, Pavel Tatashin wrote:
>> Deferred page initialization allows the boot cpu to initialize a small
>> subset of the system's pages early in boot, with other cpus doing the rest
>> later on.
>>
>
> Bit late to the game but
>
> Acked-by: Mel Gorman <mgorman@suse.de>
>
> --
> Mel Gorman
> SUSE Labs
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
