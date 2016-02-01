Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4D71D6B0005
	for <linux-mm@kvack.org>; Mon,  1 Feb 2016 10:46:11 -0500 (EST)
Received: by mail-qg0-f44.google.com with SMTP id b35so120673436qge.0
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 07:46:11 -0800 (PST)
Received: from e38.co.us.ibm.com (e38.co.us.ibm.com. [32.97.110.159])
        by mx.google.com with ESMTPS id b84si31959130qhd.120.2016.02.01.07.46.09
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 01 Feb 2016 07:46:10 -0800 (PST)
Received: from localhost
	by e38.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 1 Feb 2016 08:46:09 -0700
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 93AF13E4003F
	for <linux-mm@kvack.org>; Mon,  1 Feb 2016 08:46:06 -0700 (MST)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by b03cxnp08027.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u11Fk67Z29688002
	for <linux-mm@kvack.org>; Mon, 1 Feb 2016 08:46:06 -0700
Received: from d03av03.boulder.ibm.com (localhost [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u11Fk60r008798
	for <linux-mm@kvack.org>; Mon, 1 Feb 2016 08:46:06 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [LSF/MM ATTEND] HMM (heterogeneous memory manager) and GPU
In-Reply-To: <20160128175536.GA20797@gmail.com>
References: <20160128175536.GA20797@gmail.com>
Date: Mon, 01 Feb 2016 21:16:02 +0530
Message-ID: <87bn805t8l.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>, lsf-pc@lists.linux-foundation.org, "linux-mm@kvack.org" <linux-mm@kvack.org>

Jerome Glisse <j.glisse@gmail.com> writes:

> Hi,
>
> I would like to attend LSF/MM this year to discuss about HMM
> (Heterogeneous Memory Manager) and more generaly all topics
> related to GPU and heterogeneous memory architecture (including
> persistent memory).
>
> I want to discuss how to move forward with HMM merging and i
> hope that by MM summit time i will be able to share more
> informations publicly on devices which rely on HMM.
>

I mentioned in my request to attend mail, I would like to attend this
discussion. I am wondering whether we can split the series further to
mmu_notifier bits and then the page table mirroring bits. Can the mmu notifier
changes go in early so that we can merge the page table mirroring later ?

Can be page table mirroring bits be built as a kernel module ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
