Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 79E5C280274
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 16:48:56 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id v67so407034032pfv.1
        for <linux-mm@kvack.org>; Mon, 26 Sep 2016 13:48:56 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id e3si26699903pad.32.2016.09.26.13.48.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Sep 2016 13:48:55 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8QKm26r055689
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 16:48:55 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 25q58c08h8-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 26 Sep 2016 16:48:55 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Mon, 26 Sep 2016 14:48:53 -0600
Date: Mon, 26 Sep 2016 15:48:40 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 4/5] powerpc/mm: restore top-down allocation when
 using movable_node
References: <1474828616-16608-1-git-send-email-arbab@linux.vnet.ibm.com>
 <1474828616-16608-5-git-send-email-arbab@linux.vnet.ibm.com>
 <8760piacio.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <8760piacio.fsf@linux.vnet.ibm.com>
Message-Id: <20160926204839.bugxlsyd4p3or5p2@arbab-laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Andrew Morton <akpm@linux-foundation.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, Balbir Singh <bsingharora@gmail.com>, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, devicetree@vger.kernel.org, linux-mm@kvack.org

On Mon, Sep 26, 2016 at 09:17:43PM +0530, Aneesh Kumar K.V wrote:
>> +	/* bottom-up allocation may have been set by movable_node */
>> +	memblock_set_bottom_up(false);
>> +
>
>By then we have done few memblock allocation right ?

Yes, some allocations do occur while bottom-up is set.

>IMHO, we should do this early enough in prom.c after we do 
>parse_early_param, with a comment there explaining that, we don't 
>really support hotplug memblock and when we do that, this should be 
>moved to a place where we can handle memblock allocation such that we 
>avoid spreading memblock allocation to movable node.

Sure, we can do it earlier. The only consideration is that any potential 
calls to memblock_mark_hotplug() happen before we reset to top-down.  
Since we don't do that at all on power, the call can go anywhere.

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
