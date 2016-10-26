Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 786EE6B0273
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 13:03:56 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id n68so14645565ywn.5
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 10:03:56 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id bg13si3084258pad.65.2016.10.26.10.03.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 10:03:54 -0700 (PDT)
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9QH3r1C147019
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 13:03:53 -0400
Received: from e19.ny.us.ibm.com (e19.ny.us.ibm.com [129.33.205.209])
	by mx0b-001b2d01.pphosted.com with ESMTP id 26ay9ucjjv-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 13:03:53 -0400
Received: from localhost
	by e19.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <arbab@linux.vnet.ibm.com>;
	Wed, 26 Oct 2016 13:03:51 -0400
Date: Wed, 26 Oct 2016 12:03:44 -0500
From: Reza Arbab <arbab@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 4/5] mm: make processing of movable_node arch-specific
References: <1475778995-1420-1-git-send-email-arbab@linux.vnet.ibm.com>
 <1475778995-1420-5-git-send-email-arbab@linux.vnet.ibm.com>
 <235f2d20-cf84-08df-1fb4-08ee258fdc52@gmail.com>
 <dcfc8ace-e59e-6b4b-0f2f-4eff9f08f3c1@gmail.com>
 <20161025155507.37kv5akdlgo6m2be@arbab-laptop.austin.ibm.com>
 <112504e9-561d-e0da-7a40-73996c678b56@gmail.com>
 <20161026004929.h6v54dhehk4yvmwm@arbab-vm>
 <87vawfwfei.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <87vawfwfei.fsf@concordia.ellerman.id.au>
Message-Id: <20161026170343.2sf6qkhetfzygqya@arbab-laptop.austin.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Balbir Singh <bsingharora@gmail.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Rob Herring <robh+dt@kernel.org>, Frank Rowand <frowand.list@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Bharata B Rao <bharata@linux.vnet.ibm.com>, Nathan Fontenot <nfont@linux.vnet.ibm.com>, Stewart Smith <stewart@linux.vnet.ibm.com>, Alistair Popple <apopple@au1.ibm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, devicetree@vger.kernel.org, linux-mm@kvack.org

On Wed, Oct 26, 2016 at 09:52:53PM +1100, Michael Ellerman wrote:
>> As far as I know, power has nothing like the SRAT that tells us, at
>> boot, which memory is hotpluggable.
>
>On pseries we have the ibm,dynamic-memory device tree property, which
>can contain ranges of memory that are not yet "assigned to the
>partition" - ie. can be hotplugged later.
>
>So in general that statement is not true.
>
>But I think you're focused on bare-metal, in which case you might be
>right. But that doesn't mean we couldn't have a similar property, if
>skiboot/hostboot knew what the ranges of memory were going to be.

Yes, sorry, I should have qualified that statement to say I wasn't 
talking about pseries.

I can amend this set to actually implement movable_node on power too, 
but we'd have to settle on a name for the dt property. Is 
"linux,movable-node" too on the nose?

-- 
Reza Arbab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
