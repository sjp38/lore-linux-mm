Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f175.google.com (mail-pd0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id E122D6B0038
	for <linux-mm@kvack.org>; Tue, 18 Nov 2014 11:50:26 -0500 (EST)
Received: by mail-pd0-f175.google.com with SMTP id y10so4906636pdj.6
        for <linux-mm@kvack.org>; Tue, 18 Nov 2014 08:50:26 -0800 (PST)
Received: from fgwmail5.fujitsu.co.jp (fgwmail5.fujitsu.co.jp. [192.51.44.35])
        by mx.google.com with ESMTPS id dr2si38569582pbc.2.2014.11.18.08.50.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 18 Nov 2014 08:50:25 -0800 (PST)
Received: from kw-mxoi1.gw.nic.fujitsu.com (unknown [10.0.237.133])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 0A2093EE144
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 01:50:24 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by kw-mxoi1.gw.nic.fujitsu.com (Postfix) with ESMTP id 1944AAC0191
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 01:50:23 +0900 (JST)
Received: from g01jpfmpwkw01.exch.g01.fujitsu.local (g01jpfmpwkw01.exch.g01.fujitsu.local [10.0.193.38])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C032E1DB8038
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 01:50:22 +0900 (JST)
Received: from g01jpexchkw36.g01.fujitsu.local (unknown [10.0.193.4])
	by g01jpfmpwkw01.exch.g01.fujitsu.local (Postfix) with ESMTP id C4840692300
	for <linux-mm@kvack.org>; Wed, 19 Nov 2014 01:50:21 +0900 (JST)
Message-ID: <546B784C.4090503@jp.fujitsu.com>
Date: Wed, 19 Nov 2014 01:48:12 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 2/2] mem-hotplug: Reset node present pages when hot-adding
 a new pgdat.
References: <1415781434-20230-1-git-send-email-tangchen@cn.fujitsu.com> <1415781434-20230-3-git-send-email-tangchen@cn.fujitsu.com>
In-Reply-To: <1415781434-20230-3-git-send-email-tangchen@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>, linux-mm <linux-mm@kvack.org>, =?ISO-2022-JP?B?IklzaGltYXRzdSwgWWFzdWFraS8bJEJAUD4+GyhCIBskQkx3Pk8bKEIi?= <isimatu.yasuaki@jp.fujitsu.com>

(2014/11/12 17:37), Tang Chen wrote:
> When memory is hot-added, all the memory is in offline state. So
> clear all zones' present_pages because they will be updated in
> online_pages() and offline_pages(). Otherwise, /proc/zoneinfo
> will corrupt:
> 
> When the memory of node2 is offline:
> # cat /proc/zoneinfo
> ......
> Node 2, zone   Movable
> ......
>          spanned  8388608
>          present  8388608
>          managed  0
> 
> When we online memory on node2:
> # cat /proc/zoneinfo
> ......
> Node 2, zone   Movable
> ......
>          spanned  8388608
>          present  16777216
>          managed  8388608
> 
> Signed-off-by: Tang Chen <tangchen@cn.fujitsu.com>
> Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
> Cc: stable@vger.kernel.org # 3.16+

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
