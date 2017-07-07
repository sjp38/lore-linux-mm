Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 787216B0279
	for <linux-mm@kvack.org>; Thu,  6 Jul 2017 21:55:20 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c23so19634592pfe.11
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 18:55:20 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id v5si1240570pgb.328.2017.07.06.18.55.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Jul 2017 18:55:19 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id u36so2202484pgn.3
        for <linux-mm@kvack.org>; Thu, 06 Jul 2017 18:55:19 -0700 (PDT)
Message-ID: <1499392447.23251.1.camel@gmail.com>
Subject: Re: [RFC v5 00/11] Speculative page faults
From: Balbir Singh <bsingharora@gmail.com>
Date: Fri, 07 Jul 2017 11:54:07 +1000
In-Reply-To: <b9988c09-265a-022a-266d-e51250fe3f2c@linux.vnet.ibm.com>
References: <1497635555-25679-1-git-send-email-ldufour@linux.vnet.ibm.com>
	 <b9988c09-265a-022a-266d-e51250fe3f2c@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>

On Mon, 2017-07-03 at 19:32 +0200, Laurent Dufour wrote:
> The test is counting the number of records per second it can manage, the
> higher is the best. I run it like this 'ebizzy -mTRp'. To get consistent
> result I repeat the test 100 times and measure the average result, mean
> deviation and max. I run the test on top of 4.12 on 2 nodes, one with 80
> CPUs, and the other one with 1024 CPUs:
> 
> * 80 CPUs Power 8 node:
> Records/s	4.12		4.12-SPF
> Average		38941,62	64235,82
> Mean deviation	620,93		1718,95
> Max		41988		69623
> 
> * 1024 CPUs Power 8 node:
> Records/s	4.12		4.12-SPF
> Average		39516,64	80689,27
> Mean deviation	1387,66		1319,98
> Max		43281		90441
>

This seems like a very interesting result

Balbir Singh. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
