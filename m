Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1D4CA6B038B
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 06:00:32 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id w185so25981777ita.5
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 03:00:32 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id l6si474155iol.152.2017.02.14.03.00.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 14 Feb 2017 03:00:28 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1EAwnRs057585
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 06:00:27 -0500
Received: from e23smtp06.au.ibm.com (e23smtp06.au.ibm.com [202.81.31.148])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28kfdu01qg-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 06:00:27 -0500
Received: from localhost
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <michaele@au1.ibm.com>;
	Tue, 14 Feb 2017 21:00:24 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id B37AC2BB0045
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 22:00:22 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v1EB0E5g37093398
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 22:00:22 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v1EAxo1j017792
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 21:59:50 +1100
From: Michael Ellerman <michaele@au1.ibm.com>
Subject: Re: [PATCH V2 1/2] mm/autonuma: Let architecture override how the write bit should be stashed in a protnone pte.
In-Reply-To: <abd9d231-c380-95b0-0722-8df7be626968@linux.vnet.ibm.com>
References: <1487050314-3892-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1487050314-3892-2-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <87poilmien.fsf@concordia.ellerman.id.au> <abd9d231-c380-95b0-0722-8df7be626968@linux.vnet.ibm.com>
Date: Tue, 14 Feb 2017 21:59:23 +1100
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <874lzxm41g.fsf@concordia.ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, Rik van Riel <riel@surriel.com>, Mel Gorman <mgorman@techsingularity.net>, paulus@ozlabs.org, benh@kernel.crashing.org
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:

> On Tuesday 14 February 2017 11:19 AM, Michael Ellerman wrote:
>> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:
>>
>>> Autonuma preserves the write permission across numa fault to avoid taking
>>> a writefault after a numa fault (Commit: b191f9b106ea " mm: numa: preserve PTE
>>> write permissions across a NUMA hinting fault"). Architecture can implement
>>> protnone in different ways and some may choose to implement that by clearing Read/
>>> Write/Exec bit of pte. Setting the write bit on such pte can result in wrong
>>> behaviour. Fix this up by allowing arch to override how to save the write bit
>>> on a protnone pte.
>> This is pretty obviously a nop on arches that don't implement the new
>> hooks, but it'd still be good to get an ack from someone in mm land
>> before I merge it.
>
>
> To get it apply cleanly you may need
> http://ozlabs.org/~akpm/mmots/broken-out/mm-autonuma-dont-use-set_pte_at-when-updating-protnone-ptes.patch
> http://ozlabs.org/~akpm/mmots/broken-out/mm-autonuma-dont-use-set_pte_at-when-updating-protnone-ptes-fix.patch

Ah OK, I missed those.

In that case these two should probably go via Andrew's tree.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
