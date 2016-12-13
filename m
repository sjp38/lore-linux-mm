Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f199.google.com (mail-yb0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 55DA46B0038
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 18:12:42 -0500 (EST)
Received: by mail-yb0-f199.google.com with SMTP id d59so4537372ybi.1
        for <linux-mm@kvack.org>; Tue, 13 Dec 2016 15:12:42 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e65si15060953ywh.383.2016.12.13.15.12.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Dec 2016 15:12:41 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uBDN9FHM030004
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 18:12:41 -0500
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com [32.97.110.149])
	by mx0a-001b2d01.pphosted.com with ESMTP id 27amrw5aus-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 13 Dec 2016 18:12:41 -0500
Received: from localhost
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Tue, 13 Dec 2016 16:12:40 -0700
Date: Tue, 13 Dec 2016 17:12:36 -0600
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH v2] memory_hotplug: zone_can_shift() returns boolean value
References: <2f9c3837-33d7-b6e5-59c0-6ca4372b2d84@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <2f9c3837-33d7-b6e5-59c0-6ca4372b2d84@gmail.com>
Message-Id: <20161213231236.g6prnnjy6nyt4qkf@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <yasu.isimatu@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, isimatu.yasuaki@jp.fujitsu.com

On Tue, Dec 13, 2016 at 03:29:49PM -0500, Yasuaki Ishimatsu wrote:
>online_{kernel|movable} is used to change the memory zone to
>ZONE_{NORMAL|MOVABLE} and online the memory.
>
>To check that memory zone can be changed, zone_can_shift() is used.
>Currently the function returns minus integer value, plus integer
>value and 0. When the function returns minus or plus integer value,
>it means that the memory zone can be changed to ZONE_{NORNAL|MOVABLE}.
>
>But when the function returns 0, there is 2 meanings.
>
>One of the meanings is that the memory zone does not need to be changed.
>For example, when memory is in ZONE_NORMAL and onlined by online_kernel
>the memory zone does not need to be changed.
>
>Another meaning is that the memory zone cannot be changed. When memory
>is in ZONE_NORMAL and onlined by online_movable, the memory zone may
>not be changed to ZONE_MOVALBE due to memory online limitation(see
>Documentation/memory-hotplug.txt). In this case, memory must not be
>onlined.
>
>The patch changes the return type of zone_can_shift() so that memory
>is not onlined when memory zone cannot be changed.

Reviewed-by: Reza Arbab <arbab@linux.vnet.ibm.com>

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
