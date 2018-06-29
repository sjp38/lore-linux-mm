Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 956A66B0007
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 10:12:56 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id s24-v6so7056525iob.5
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 07:12:56 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id i134-v6si6727917ioe.128.2018.06.29.07.12.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 07:12:55 -0700 (PDT)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w5TE9AjP135290
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 14:12:54 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2120.oracle.com with ESMTP id 2jukhspss5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 14:12:54 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w5TECrde013023
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 14:12:53 GMT
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w5TECrXH023522
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 14:12:53 GMT
Received: by mail-oi0-f45.google.com with SMTP id m2-v6so617956oim.12
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 07:12:52 -0700 (PDT)
MIME-Version: 1.0
References: <1530279308-24988-1-git-send-email-rppt@linux.vnet.ibm.com>
In-Reply-To: <1530279308-24988-1-git-send-email-rppt@linux.vnet.ibm.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 29 Jun 2018 10:12:16 -0400
Message-ID: <CAGM2reZvBhfW314XcR7srQhZf-bZMyCXR+9_X4Qtro7i-don5g@mail.gmail.com>
Subject: Re: [PATCH] mm: make DEFERRED_STRUCT_PAGE_INIT explicitly depend on SPARSEMEM
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: rppt@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

This is something I also wanted to see, thank you.

Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
