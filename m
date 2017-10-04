Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id BFD116B0038
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 02:51:03 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id y138so7468181itc.13
        for <linux-mm@kvack.org>; Tue, 03 Oct 2017 23:51:03 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id 32si5803254qtu.211.2017.10.03.23.51.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Oct 2017 23:51:03 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v946ncmB119868
	for <linux-mm@kvack.org>; Wed, 4 Oct 2017 02:51:02 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2dctpw03pd-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 04 Oct 2017 02:51:01 -0400
Received: from localhost
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Wed, 4 Oct 2017 07:50:59 +0100
Subject: Re: [PATCH v3 00/20] Speculative page faults
References: <CAADnVQLmSbLHwj9m33kpzAidJPvq3cbdnXjaew6oTLqHWrBbZQ@mail.gmail.com>
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Date: Wed, 4 Oct 2017 08:50:49 +0200
MIME-Version: 1.0
In-Reply-To: <CAADnVQLmSbLHwj9m33kpzAidJPvq3cbdnXjaew6oTLqHWrBbZQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Message-Id: <670c9a22-cf5b-3fab-b2f2-a72fbd4451c8@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, kirill@shutemov.name, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, dave@stgolabs.net, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, haren@linux.vnet.ibm.com, Anshuman Khandual <khandual@linux.vnet.ibm.com>, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, "x86@kernel.org" <x86@kernel.org>

On 25/09/2017 18:27, Alexei Starovoitov wrote:
> On Mon, Sep 18, 2017 at 12:15 AM, Laurent Dufour
> <ldufour@linux.vnet.ibm.com> wrote:
>> Despite the unprovable lockdep warning raised by Sergey, I didn't get any
>> feedback on this series.
>>
>> Is there a chance to get it moved upstream ?
> 
> what is the status ?
> We're eagerly looking forward for this set to land,
> since we have several use cases for tracing that
> will build on top of this set as discussed at Plumbers.

Hi Alexei,

Based on Plumber's note [1], it sounds that the use case is tied to the BPF
tracing where a call tp find_vma() call will be made on a process's context
to fetch user space's symbols.

Am I right ?
Is the find_vma() call made in the context of the process owning the mm
struct ?

Thanks,
Laurent.

[1] https://etherpad.openstack.org/p/LPC2017_Tracing)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
