Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8F2276B0038
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 21:57:45 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id c67so32117286ywe.1
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 18:57:45 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id i74si2367516qka.85.2016.08.31.18.57.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 18:57:39 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u811rttW057700
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 21:57:39 -0400
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2569ecc2pr-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 21:57:39 -0400
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Wed, 31 Aug 2016 19:57:38 -0600
Date: Wed, 31 Aug 2016 20:57:29 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [RESEND PATCH v2] memory-hotplug: fix store_mem_state() return
 value
References: <20160831150105.GB26702@kroah.com>
 <1472658241-32748-1-git-send-email-arbab@linux.vnet.ibm.com>
 <20160831132557.c5cf0985e3da5f2850a10b1d@linux-foundation.org>
 <alpine.DEB.2.10.1608311402520.33967@chino.kir.corp.google.com>
 <20160831233811.g6kf24fdhnfhn637@arbab-vm>
 <alpine.DEB.2.10.1608311652110.112811@chino.kir.corp.google.com>
 <20160901001751.m3z2snlop2djzqgd@arbab-vm>
 <alpine.DEB.2.10.1608311722080.24833@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1608311722080.24833@chino.kir.corp.google.com>
Message-Id: <20160901015729.426os236ao6j5qvd@arbab-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vitaly Kuznetsov <vkuznets@redhat.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dan Williams <dan.j.williams@intel.com>, Xishi Qiu <qiuxishi@huawei.com>, David Vrabel <david.vrabel@citrix.com>, Chen Yucong <slaoub@gmail.com>, Andrew Banman <abanman@sgi.com>, Seth Jennings <sjenning@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 31, 2016 at 05:28:26PM -0700, David Rientjes wrote:
>> 2. store_mem_state() still needs a tweak, right? It was only 
>> returning -EINVAL by accident, due to the convoluted sequence I 
>> listed in the patch.
>
>Yes, absolutely.  It returning -EINVAL for "nline" is what is accidently
>preserving it's backwards compatibility :)  Note that device_online()
>returns 1 if already online and memory_subsys_online() returns 0 if online
>in this case.  So we want store_mem_state() to return -EINVAL if
>device_online() returns non-zero (this was in my first email).

I'll spin a v3 patch to do this.

Thank you for your review!

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
