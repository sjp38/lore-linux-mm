Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id B18466B0007
	for <linux-mm@kvack.org>; Thu,  8 Feb 2018 19:58:52 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id e64so6587483itd.1
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 16:58:52 -0800 (PST)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id 73si867648iod.309.2018.02.08.16.58.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Feb 2018 16:58:51 -0800 (PST)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w190vqaK172711
	for <linux-mm@kvack.org>; Fri, 9 Feb 2018 00:58:50 GMT
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
	by userp2130.oracle.com with ESMTP id 2g11csr1h3-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 09 Feb 2018 00:58:50 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w190wU40029784
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 9 Feb 2018 00:58:30 GMT
Received: from abhmp0019.oracle.com (abhmp0019.oracle.com [141.146.116.25])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w190wTkX011079
	for <linux-mm@kvack.org>; Fri, 9 Feb 2018 00:58:29 GMT
Received: by mail-ot0-f180.google.com with SMTP id 73so6133941oti.12
        for <linux-mm@kvack.org>; Thu, 08 Feb 2018 16:58:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <92cb25ed-cd60-f3fa-dde5-72aa8b839808@oracle.com>
References: <20180208184555.5855-1-pasha.tatashin@oracle.com>
 <20180208184555.5855-2-pasha.tatashin@oracle.com> <20180208120334.0779ed0726bb527a9cad0336@linux-foundation.org>
 <92cb25ed-cd60-f3fa-dde5-72aa8b839808@oracle.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Thu, 8 Feb 2018 19:58:28 -0500
Message-ID: <CAOAebxssDZvLyHMCiYieaFMvC6S+CSpN76C_VP6zdM_UvC8wKQ@mail.gmail.com>
Subject: Re: [PATCH v2 1/1] mm: initialize pages on demand during boot
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Steve Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, m.mizuma@jp.fujitsu.com, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, baiyaowei@cmss.chinamobile.com, Wei Yang <richard.weiyang@gmail.com>, Paul Burton <paul.burton@mips.com>, Miles Chen <miles.chen@mediatek.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

>>
>> It would be nice to have a little comment explaining why READ_ONCE was
>> needed.
>>
>> Would it still be needed if this code was moved into the locked region?
>
>
> No, we would need to use READ_ONCE() if we grabbed deferred_zone_grow_lock
> before this code. In fact I do not even think we strictly need READ_ONCE()
> here, as it is a single load anyway. But, because we are outside of the
> lock, and we want to quickly fetch the data with a single load, I think it
> makes sense to emphasize it using READ_ONCE() without expected compiler to
> simply do the write thing for us.
>
>

Correction:

No, we would NOT need ...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
