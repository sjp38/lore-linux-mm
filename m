Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id F20116B0005
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 10:39:15 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l4so63859651wml.0
        for <linux-mm@kvack.org>; Wed, 10 Aug 2016 07:39:15 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id 62si8268063wmv.71.2016.08.10.07.39.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Aug 2016 07:39:15 -0700 (PDT)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7AETGB0115955
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 10:39:13 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0b-001b2d01.pphosted.com with ESMTP id 24qm9u9qm9-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 10 Aug 2016 10:39:13 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <nfont@linux.vnet.ibm.com>;
	Wed, 10 Aug 2016 08:39:12 -0600
Subject: Re: [PATCH 0/4] powerpc/mm: movable hotplug memory nodes
References: <1470680843-28702-1-git-send-email-arbab@linux.vnet.ibm.com>
 <87shucsypn.fsf@concordia.ellerman.id.au>
From: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Date: Wed, 10 Aug 2016 09:39:05 -0500
MIME-Version: 1.0
In-Reply-To: <87shucsypn.fsf@concordia.ellerman.id.au>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <76b4ef23-be57-8138-8117-77531750539e@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>, Reza Arbab <arbab@linux.vnet.ibm.com>, Rob Herring <robh+dt@kernel.org>, Mark Rutland <mark.rutland@arm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Jonathan Corbet <corbet@lwn.net>, Bharata B Rao <bharata@linux.vnet.ibm.com>, devicetree@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 08/10/2016 05:30 AM, Michael Ellerman wrote:
> Reza Arbab <arbab@linux.vnet.ibm.com> writes:
> 
>> These changes enable onlining memory into ZONE_MOVABLE on power, and the
>> creation of discrete nodes of movable memory.
>>
>> Node hotplug is not supported on power [1].
> 
> But maybe it should be?
> 
Yes, it should be supported.

I have briefly looked into this recently only to find
this will not be a simple update.

-Nathan 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
