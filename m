Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0F2C86B0291
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 10:57:17 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 3so105477884pgd.3
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 07:57:17 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id s199si27033681pgs.43.2016.11.15.07.57.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 07:57:16 -0800 (PST)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uAFFsNIh100731
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 10:57:15 -0500
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26r2qs0tq4-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 10:57:15 -0500
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Tue, 15 Nov 2016 08:57:14 -0700
Date: Tue, 15 Nov 2016 09:57:07 -0600
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH v7 2/5] mm: remove x86-only restriction of movable_node
References: <1479160961-25840-1-git-send-email-arbab@linux.vnet.ibm.com>
 <1479160961-25840-3-git-send-email-arbab@linux.vnet.ibm.com>
 <87lgwlb4u1.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <87lgwlb4u1.fsf@linux.vnet.ibm.com>
Message-Id: <20161115155706.zft7iaw2fjtwu7yp@arbab-laptop.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Michael Ellerman <mpe@ellerman.id.au>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Andrew Morton <akpm@linux-foundation.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org, devicetree@vger.kernel.org, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, Balbir Singh <bsingharora@gmail.com>, linux-kernel@vger.kernel.org

On Tue, Nov 15, 2016 at 12:35:42PM +0530, Aneesh Kumar K.V wrote:
>Considering that we now can mark memblock hotpluggable, do we need to
>enable the bottom up allocation for ppc64 also ?

No, we don't, because early_init_dt_scan_memory() marks the memblocks 
hotpluggable immediately when they are added. There is no gap between 
the addition and the marking, as there is on x86, during which an 
allocation might accidentally occur in a movable node.

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
