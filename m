Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 58A6B6B002E
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 09:34:48 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id p125so5389959ywb.10
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 06:34:48 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 8si7864908qtw.118.2018.04.13.06.34.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Apr 2018 06:34:47 -0700 (PDT)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3DDXRqw115247
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 09:34:46 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2havvf2an3-1
	(version=TLSv1.2 cipher=AES256-SHA256 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 09:34:45 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Fri, 13 Apr 2018 14:34:42 +0100
Subject: Re: [PATCH v9 00/24] Speculative page faults
References: <1520963994-28477-1-git-send-email-ldufour@linux.vnet.ibm.com>
 <20180314131118.GC23100@dhcp22.suse.cz>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Fri, 13 Apr 2018 15:34:33 +0200
MIME-Version: 1.0
In-Reply-To: <20180314131118.GC23100@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <78f7f2c0-40e6-f080-e531-70305530f1ce@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: paulmck@linux.vnet.ibm.com, peterz@infradead.org, akpm@linux-foundation.org, kirill@shutemov.name, ak@linux.intel.com, dave@stgolabs.net, jack@suse.cz, Matthew Wilcox <willy@infradead.org>, benh@kernel.crashing.org, mpe@ellerman.id.au, paulus@samba.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, hpa@zytor.com, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Alexei Starovoitov <alexei.starovoitov@gmail.com>, kemi.wang@intel.com, sergey.senozhatsky.work@gmail.com, Daniel Jordan <daniel.m.jordan@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, haren@linux.vnet.ibm.com, khandual@linux.vnet.ibm.com, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org

On 14/03/2018 14:11, Michal Hocko wrote:
> On Tue 13-03-18 18:59:30, Laurent Dufour wrote:
>> Changes since v8:
>>  - Don't check PMD when locking the pte when THP is disabled
>>    Thanks to Daniel Jordan for reporting this.
>>  - Rebase on 4.16
> 
> Is this really worth reposting the whole pile? I mean this is at v9,
> each doing little changes. It is quite tiresome to barely get to a
> bookmarked version just to find out that there are 2 new versions out.
> 
> I am sorry to be grumpy and I can understand some frustration it doesn't
> move forward that easilly but this is a _big_ change. We should start
> with a real high level review rather than doing small changes here and
> there and reach v20 quickly.

I know this would mean v10, but there has been a bunch of reviews from David
Rientjes and Jerome Glisse, and I had to make many changes to address them.
So I think this is time to push a v10.

If you have already started a review of this v9 series, please send me your
remarks so that I can compile them in this v10 asap.

Thanks,
Laurent.
