Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8FB506B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 05:45:22 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id d8so20961686pgt.1
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 02:45:22 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e4si5598132pln.412.2017.09.26.02.45.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Sep 2017 02:45:21 -0700 (PDT)
Subject: Re: [RFC] a question about mlockall() and mprotect()
References: <59CA0847.8000508@huawei.com>
 <20170926081716.xo375arjoyu5ytcb@dhcp22.suse.cz>
 <59CA125C.8000801@huawei.com>
 <20170926090255.jmocezs6s3lpd6p4@dhcp22.suse.cz>
 <59CA1A57.5000905@huawei.com> <59CA1C6E.4010501@huawei.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6b38ed08-62cb-97b1-9f16-1fd8e272b137@suse.cz>
Date: Tue, 26 Sep 2017 11:45:16 +0200
MIME-Version: 1.0
In-Reply-To: <59CA1C6E.4010501@huawei.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>, Michal Hocko <mhocko@kernel.org>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, zhong jiang <zhongjiang@huawei.com>, yeyunfeng <yeyunfeng@huawei.com>, wanghaitao12@huawei.com, "Zhoukang (A)" <zhoukang7@huawei.com>

On 09/26/2017 11:22 AM, Xishi Qiu wrote:
> On 2017/9/26 17:13, Xishi Qiu wrote:
>>> This is still very fuzzy. What are you actually trying to achieve?
>>
>> I don't expect page fault any more after mlock.
>>
> 
> Our apps is some thing like RT, and page-fault maybe cause a lot of time,
> e.g. lock, mem reclaim ..., so I use mlock and don't want page fault
> any more.

Why does your app then have restricted mprotect when calling mlockall()
and only later adjusts the mprotect?

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
