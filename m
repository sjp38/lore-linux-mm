Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4A6E86B000A
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 04:15:27 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id b76-v6so6685743ywb.11
        for <linux-mm@kvack.org>; Fri, 12 Oct 2018 01:15:27 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id p123-v6si159027ywe.365.2018.10.12.01.15.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Oct 2018 01:15:26 -0700 (PDT)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w9C8Elrc010746
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 04:15:25 -0400
Received: from e15.ny.us.ibm.com (e15.ny.us.ibm.com [129.33.205.205])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2n2pugan13-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 12 Oct 2018 04:15:25 -0400
Received: from localhost
	by e15.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <zaslonko@linux.ibm.com>;
	Fri, 12 Oct 2018 04:15:25 -0400
From: Zaslonko Mikhail <zaslonko@linux.ibm.com>
Subject: Memory hotplug vmem pages
Date: Fri, 12 Oct 2018 10:15:26 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Message-Id: <17182cdc-cffe-ca39-f5c0-d1c5bd7ec4cb@linux.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>

Hello Michal,

I've read a recent discussion about introducing the memory types for 
memory hotplug:
https://marc.info/?t=153814716600004&r=1&w=2

In particular I was interested in the idea of moving vmem struct pages 
to the hotplugable memory itself. I'm also looking into it for s390 
right now. So, in one of your replies you mentioned that you "have 
proposed (but haven't finished this due to other stuff) a solution for 
this". Have you covered any part of that solution yet? Could you please 
point me to any relevant discussions on this matter?

Thanks,
Mikhail Zaslonko
