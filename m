Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id C29676B0038
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 19:38:21 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id ez1so122940138pab.1
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 16:38:21 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id t2si1900469qkf.161.2016.08.31.16.38.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 31 Aug 2016 16:38:21 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u7VNZYUC134310
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 19:38:20 -0400
Received: from e33.co.us.ibm.com (e33.co.us.ibm.com [32.97.110.151])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2568xs89kn-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 19:38:20 -0400
Received: from localhost
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Wed, 31 Aug 2016 17:38:19 -0600
Date: Wed, 31 Aug 2016 18:38:12 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [RESEND PATCH v2] memory-hotplug: fix store_mem_state() return
 value
References: <20160831150105.GB26702@kroah.com>
 <1472658241-32748-1-git-send-email-arbab@linux.vnet.ibm.com>
 <20160831132557.c5cf0985e3da5f2850a10b1d@linux-foundation.org>
 <alpine.DEB.2.10.1608311402520.33967@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1608311402520.33967@chino.kir.corp.google.com>
Message-Id: <20160831233811.g6kf24fdhnfhn637@arbab-vm>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vitaly Kuznetsov <vkuznets@redhat.com>, Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dan Williams <dan.j.williams@intel.com>, Xishi Qiu <qiuxishi@huawei.com>, David Vrabel <david.vrabel@citrix.com>, Chen Yucong <slaoub@gmail.com>, Andrew Banman <abanman@sgi.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Aug 31, 2016 at 02:06:14PM -0700, David Rientjes wrote:
>The correct fix is for store_mem_state() to return -EINVAL when 
>device_online() returns non-zero.

Let me put it to you this way--which one of these sysfs operations is 
behaving correctly?

	# cd /sys/devices/system/memory/memory0
	# cat online
	1
	# echo 1 > online; echo $?
	0

or

	# cd /sys/devices/system/memory/memory0
	# cat state
	online
	# echo online > state; echo $?
	-bash: echo: write error: Invalid argument
	1

One of them should change to match the other.

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
