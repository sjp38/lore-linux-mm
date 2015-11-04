Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 5A27B6B0253
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 01:57:12 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so44057420pab.0
        for <linux-mm@kvack.org>; Tue, 03 Nov 2015 22:57:12 -0800 (PST)
Received: from mgwkm01.jp.fujitsu.com (mgwkm01.jp.fujitsu.com. [202.219.69.168])
        by mx.google.com with ESMTPS id nz1si5859244pbb.112.2015.11.03.22.57.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Nov 2015 22:57:11 -0800 (PST)
Received: from m3051.s.css.fujitsu.com (m3051.s.css.fujitsu.com [10.134.21.209])
	by kw-mxq.gw.nic.fujitsu.com (Postfix) with ESMTP id 69B0EAC0134
	for <linux-mm@kvack.org>; Wed,  4 Nov 2015 15:57:06 +0900 (JST)
Subject: Re: [PATCH] mm: Introduce kernelcore=reliable option
References: <1444915942-15281-1-git-send-email-izumi.taku@jp.fujitsu.com>
 <3908561D78D1C84285E8C5FCA982C28F32B5A060@ORSMSX114.amr.corp.intel.com>
 <5628B427.3050403@jp.fujitsu.com>
 <3908561D78D1C84285E8C5FCA982C28F32B5C7AE@ORSMSX114.amr.corp.intel.com>
 <E86EADE93E2D054CBCD4E708C38D364A54280C26@G01JPEXMBYT01>
 <322B7BFA-08FE-4A8F-B54C-86901BDB7CBD@intel.com>
 <56330C0A.3060901@jp.fujitsu.com>
 <3908561D78D1C84285E8C5FCA982C28F32B64312@ORSMSX114.amr.corp.intel.com>
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <5639AC34.9030603@jp.fujitsu.com>
Date: Wed, 4 Nov 2015 15:56:52 +0900
MIME-Version: 1.0
In-Reply-To: <3908561D78D1C84285E8C5FCA982C28F32B64312@ORSMSX114.amr.corp.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>, "Izumi, Taku" <izumi.taku@jp.fujitsu.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>, "mel@csn.ul.ie" <mel@csn.ul.ie>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "Hansen, Dave" <dave.hansen@intel.com>, "matt@codeblueprint.co.uk" <matt@codeblueprint.co.uk>

On 2015/10/31 4:42, Luck, Tony wrote:
>> If each memory controller has the same distance/latency, you (your firmware) don't need
>> to allocate reliable memory per each memory controller.
>> If distance is problem, another node should be allocated.
>>
>> ...is the behavior(splitting zone) really required ?
>
> It's useful from a memory bandwidth perspective to have allocations
> spread across both memory controllers. Keeping a whole bunch of
> Xeon cores fed needs all the bandwidth you can get.
>

Hmm. But physical address layout is not related to dual memory controller.
I think reliable range can be contiguous by firmware...

-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
