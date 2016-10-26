Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 599556B0274
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 07:09:31 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id i85so150540767pfa.5
        for <linux-mm@kvack.org>; Wed, 26 Oct 2016 04:09:31 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id s6si1699653pax.104.2016.10.26.04.09.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Oct 2016 04:09:30 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9QB92GJ076511
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 07:09:29 -0400
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com [32.97.110.152])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26aqjw3u6u-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 26 Oct 2016 07:09:29 -0400
Received: from localhost
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Wed, 26 Oct 2016 05:09:28 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC 0/8] Define coherent device memory node
In-Reply-To: <20161025151637.GA6072@gmail.com>
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com> <20161024170902.GA5521@gmail.com> <87a8dtawas.fsf@linux.vnet.ibm.com> <20161025151637.GA6072@gmail.com>
Date: Wed, 26 Oct 2016 16:39:19 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87y41bcqow.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, bsingharora@gmail.com

Jerome Glisse <j.glisse@gmail.com> writes:

> On Tue, Oct 25, 2016 at 09:56:35AM +0530, Aneesh Kumar K.V wrote:
>> Jerome Glisse <j.glisse@gmail.com> writes:
>> 
>> > On Mon, Oct 24, 2016 at 10:01:49AM +0530, Anshuman Khandual wrote:
>> >
>> I looked at the hmm-v13 w.r.t migration and I guess some form of device
>> callback/acceleration during migration is something we should definitely
>> have. I still haven't figured out how non addressable and coherent device
>> memory can fit together there. I was waiting for the page cache
>> migration support to be pushed to the repository before I start looking
>> at this closely.
>> 
>
> The page cache migration does not touch the migrate code path. My issue with
> page cache is writeback. The only difference with existing migrate code is
> refcount check for ZONE_DEVICE page. Everything else is the same.

What about the radix tree ? does file system migrate_page callback handle
replacing normal page with ZONE_DEVICE page/exceptional entries ?

>
> For writeback i need to use a bounce page so basicly i am trying to hook myself
> along the ISA bounce infrastructure for bio and i think it is the easiest path
> to solve this in my case.
>
> In your case where block device can also access the device memory you don't
> even need to use bounce page for writeback.
>

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
