Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DC7926B0069
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 03:34:48 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id j128so342063617pfg.4
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 00:34:48 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id y1si68467764pfd.3.2016.12.01.00.34.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 00:34:48 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uB18YiTo078214
	for <linux-mm@kvack.org>; Thu, 1 Dec 2016 03:34:47 -0500
Received: from e06smtp08.uk.ibm.com (e06smtp08.uk.ibm.com [195.75.94.104])
	by mx0a-001b2d01.pphosted.com with ESMTP id 272fskt3mq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 01 Dec 2016 03:34:47 -0500
Received: from localhost
	by e06smtp08.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Thu, 1 Dec 2016 08:34:17 -0000
Received: from b06cxnps4074.portsmouth.uk.ibm.com (d06relay11.portsmouth.uk.ibm.com [9.149.109.196])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id C9BFF1B0805F
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 08:36:37 +0000 (GMT)
Received: from d06av06.portsmouth.uk.ibm.com (d06av06.portsmouth.uk.ibm.com [9.149.37.217])
	by b06cxnps4074.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uB18YFG966584774
	for <linux-mm@kvack.org>; Thu, 1 Dec 2016 08:34:15 GMT
Received: from d06av06.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av06.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uB18YEfY026526
	for <linux-mm@kvack.org>; Thu, 1 Dec 2016 03:34:15 -0500
Subject: Re: [RFC PATCH v2 0/7] Speculative page faults
References: <20161018150243.GZ3117@twins.programming.kicks-ass.net>
 <cover.1479465699.git.ldufour@linux.vnet.ibm.com>
 <871sy8284n.fsf@tassilo.jf.intel.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Thu, 1 Dec 2016 09:34:14 +0100
MIME-Version: 1.0
In-Reply-To: <871sy8284n.fsf@tassilo.jf.intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <885a17ba-fed8-e312-c2d3-e28a996f5424@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: "Kirill A . Shutemov" <kirill@shutemov.name>, Peter Zijlstra <peterz@infradead.org>, Linux MM <linux-mm@kvack.org>, Michal Hocko <mhocko@suse.cz>

On 18/11/2016 15:08, Andi Kleen wrote:
> Laurent Dufour <ldufour@linux.vnet.ibm.com> writes:
> 
>> This is a port on kernel 4.8 of the work done by Peter Zijlstra to
>> handle page fault without holding the mm semaphore.
> 
> One of the big problems with patches like this today is that it is
> unclear what mmap_sem actually protects. It's a big lock covering lots
> of code. Parts in the core VM, but also do VM callbacks in file systems
> and drivers rely on it too?
> 
> IMHO the first step is a comprehensive audit and then writing clear
> documentation on what it is supposed to protect. Then based on that such
> changes can be properly evaluated.

Hi Andi,

Sorry for the late answer...

I do agree, this semaphore is massively used and it would be nice to
have all its usage documented.

I'm currently tracking all the mmap_sem use in 4.8 kernel (about 380
hits) and I'm trying to identify which it is protecting.

In addition, I think it may be nice to limit its usage to code under mm/
so that in the future it may be easier to find its usage.

Thanks,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
