Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 29D256B0266
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 14:20:10 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id tz10so17650253pab.3
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:20:10 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f19si16712292pff.176.2016.10.24.11.20.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 11:20:09 -0700 (PDT)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9OIId7g082878
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 14:20:08 -0400
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com [32.97.110.159])
	by mx0a-001b2d01.pphosted.com with ESMTP id 269kv7k783-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 14:20:08 -0400
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Mon, 24 Oct 2016 12:20:07 -0600
Date: Mon, 24 Oct 2016 13:20:00 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 2/5] drivers/of: do not add memory for unavailable
 nodes
References: <1475778995-1420-1-git-send-email-arbab@linux.vnet.ibm.com>
 <1475778995-1420-3-git-send-email-arbab@linux.vnet.ibm.com>
 <2344394.NlaWgtFOqB@new-mexico>
 <87vawixcxn.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <87vawixcxn.fsf@concordia.ellerman.id.au>
Message-Id: <20161024182000.5g2f3w3x3oqrohqs@arbab-laptop.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, Alistair Popple <apopple@au1.ibm.com>
Cc: linuxppc-dev@lists.ozlabs.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Stewart Smith <stewart@linux.vnet.ibm.com>, devicetree@vger.kernel.org, linux-kernel@vger.kernel.org, Tang Chen <tangchen@cn.fujitsu.com>, linux-mm@kvack.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>

On Mon, Oct 24, 2016 at 09:24:04PM +1100, Michael Ellerman wrote:
>The code already looks for "linux,usable-memory" in preference to 
>"reg". Can you use that instead?

Yes, we could set the size of "linux,usable-memory" to zero instead of 
setting status to "disabled".

I'll send a v5 of this set which drops 1/5 and 2/5. That would be the 
only difference here.

>That would have the advantage that existing kernels already understand
>it.
>
>Another problem with using "status" is we could have device trees out
>there that have status = disabled and we don't know about it, and by
>changing the kernel to use that property we break people's systems.
>Though for memory nodes my guess is that's not true, but you never know ...

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
