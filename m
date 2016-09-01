Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 873D26B0038
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 20:18:02 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id vd14so124973113pab.3
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 17:18:02 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z25si2301956pff.143.2016.08.31.17.18.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 17:18:01 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u810G6ZJ120282
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 20:18:01 -0400
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2569e20mws-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 20:18:01 -0400
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Wed, 31 Aug 2016 18:18:00 -0600
Date: Wed, 31 Aug 2016 19:17:51 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [RESEND PATCH v2] memory-hotplug: fix store_mem_state() return
 value
References: <20160831150105.GB26702@kroah.com>
 <1472658241-32748-1-git-send-email-arbab@linux.vnet.ibm.com>
 <20160831132557.c5cf0985e3da5f2850a10b1d@linux-foundation.org>
 <alpine.DEB.2.10.1608311402520.33967@chino.kir.corp.google.com>
 <20160831233811.g6kf24fdhnfhn637@arbab-vm>
 <alpine.DEB.2.10.1608311652110.112811@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1608311652110.112811@chino.kir.corp.google.com>
Message-Id: <20160901001751.m3z2snlop2djzqgd@arbab-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vitaly Kuznetsov <vkuznets@redhat.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dan Williams <dan.j.williams@intel.com>, Xishi Qiu <qiuxishi@huawei.com>, David Vrabel <david.vrabel@citrix.com>, Chen Yucong <slaoub@gmail.com>, Andrew Banman <abanman@sgi.com>, Seth Jennings <sjenning@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 31, 2016 at 05:03:25PM -0700, David Rientjes wrote:
>Nope, the return value of changing state from online to online was
>established almost 11 years ago in commit 3947be1969a9.

Fair enough. So if online-to-online is -EINVAL, 

1. Shouldn't 'echo 1 > online' then also return -EINVAL?

2. store_mem_state() still needs a tweak, right? It was only returning 
-EINVAL by accident, due to the convoluted sequence I listed in the 
patch.

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
