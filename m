Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id A37C96B0269
	for <linux-mm@kvack.org>; Fri,  4 May 2018 09:01:10 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id y12so9179530pfe.8
        for <linux-mm@kvack.org>; Fri, 04 May 2018 06:01:10 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id t3-v6si13069903pgf.356.2018.05.04.06.01.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 04 May 2018 06:01:07 -0700 (PDT)
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
	by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w44CfKcl157110
	for <linux-mm@kvack.org>; Fri, 4 May 2018 13:01:07 GMT
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
	by userp2120.oracle.com with ESMTP id 2hmhmfwv1b-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 04 May 2018 13:01:07 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w44D16P3015741
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 4 May 2018 13:01:06 GMT
Received: from abhmp0006.oracle.com (abhmp0006.oracle.com [141.146.116.12])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w44D15Sb005370
	for <linux-mm@kvack.org>; Fri, 4 May 2018 13:01:05 GMT
Received: by mail-ot0-f178.google.com with SMTP id t1-v6so24363147oth.8
        for <linux-mm@kvack.org>; Fri, 04 May 2018 06:01:05 -0700 (PDT)
MIME-Version: 1.0
References: <20180504085311.1240-1-Jonathan.Cameron@huawei.com>
In-Reply-To: <20180504085311.1240-1-Jonathan.Cameron@huawei.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 04 May 2018 13:00:29 +0000
Message-ID: <CAGM2reYRmzzDwyuLwUeusZdQPXseQ=C5uOUS-DopLm8KqyJ1Ew@mail.gmail.com>
Subject: Re: [PATCH] mm/memory_hotplug: Fix leftover use of struct page during hotplug
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jonathan.Cameron@huawei.com
Cc: Linux Memory Management List <linux-mm@kvack.org>, linuxarm@huawei.com, Andrew Morton <akpm@linux-foundation.org>

Hi Jonathan,

Thank you for the fix:
Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
