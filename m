Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 063086B029E
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 02:28:30 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id j16so4357057pga.6
        for <linux-mm@kvack.org>; Sun, 10 Sep 2017 23:28:29 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u7si5639791pfl.547.2017.09.10.23.28.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 10 Sep 2017 23:28:28 -0700 (PDT)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8B6P4l1078829
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 02:28:27 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2cwcybhew6-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 02:28:27 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Mon, 11 Sep 2017 07:28:25 +0100
Subject: Re: [PATCH v2 00/20] Speculative page faults
References: <1503007519-26777-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <20170821022629.GA541@jagdpanzerIV.localdomain>
 <6302a906-221d-c977-4aea-67202eb3d96d@linux.vnet.ibm.com>
 <20170911004523.GA2938@jagdpanzerIV.localdomain>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Mon, 11 Sep 2017 08:28:16 +0200
MIME-Version: 1.0
In-Reply-To: <20170911004523.GA2938@jagdpanzerIV.localdomain>
Content-Type: text/plain; charset=utf-8
Content-Language: fr
Content-Transfer-Encoding: 7bit
Message-Id: <da0e23a5-f2b9-bd84-8f62-0a84d1194bd7@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, mhocko@kernel.org, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 11/09/2017 02:45, Sergey Senozhatsky wrote:
> On (09/08/17 11:24), Laurent Dufour wrote:
>> Hi Sergey,
>>
>> I can't see where such a chain could happen.
>>
>> I tried to recreate it on top of the latest mm tree, to latest stack output
>> but I can't get it.
>> How did you raised this one ?
> 
> Hi Laurent,
> 
> didn't do anything special, the box even wasn't under severe memory
> pressure. can re-test your new patch set.

Hi Sergey,

I sent a v3 series, would you please give it a try ?

Thanks,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
