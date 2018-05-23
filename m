Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 752526B0266
	for <linux-mm@kvack.org>; Wed, 23 May 2018 09:14:50 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id e4-v6so22127039qtp.15
        for <linux-mm@kvack.org>; Wed, 23 May 2018 06:14:50 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id p63-v6si348140qkb.198.2018.05.23.06.14.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 May 2018 06:14:49 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w4NDBGVo042911
	for <linux-mm@kvack.org>; Wed, 23 May 2018 13:14:48 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2120.oracle.com with ESMTP id 2j4nh7ux46-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 23 May 2018 13:14:48 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w4NDEkgo019388
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 23 May 2018 13:14:46 GMT
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w4NDEjVl015227
	for <linux-mm@kvack.org>; Wed, 23 May 2018 13:14:45 GMT
Received: by mail-oi0-f44.google.com with SMTP id l1-v6so19444319oii.1
        for <linux-mm@kvack.org>; Wed, 23 May 2018 06:14:45 -0700 (PDT)
MIME-Version: 1.0
References: <20180523125555.30039-1-mhocko@kernel.org> <20180523125555.30039-2-mhocko@kernel.org>
In-Reply-To: <20180523125555.30039-2-mhocko@kernel.org>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Wed, 23 May 2018 09:14:08 -0400
Message-ID: <CAGM2reYGN+yrDP_cUY1rPOpy7owdvQLqfrYqF9YSDPKdJOGEeg@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm, memory_hotplug: make has_unmovable_pages more robust
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>, osalvador@techadventures.net, Vlastimil Babka <vbabka@suse.cz>, arbab@linux.vnet.ibm.com, imammedo@redhat.com, vkuznets@redhat.com, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.com>

Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
