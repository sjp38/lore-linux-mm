Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id C67C76B0038
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 04:30:37 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id u48so10502770qtc.3
        for <linux-mm@kvack.org>; Tue, 26 Sep 2017 01:30:37 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id a22si3645724qtc.268.2017.09.26.01.30.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Sep 2017 01:30:37 -0700 (PDT)
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8Q8TG79087957
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 04:30:36 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2d7jgwujvw-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 26 Sep 2017 04:30:35 -0400
Received: from localhost
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <ldufour@linux.vnet.ibm.com>;
	Tue, 26 Sep 2017 09:30:33 +0100
From: Laurent Dufour <ldufour@linux.vnet.ibm.com>
Subject: Re: [PATCH v3 00/20] Speculative page faults
References: <CAADnVQLmSbLHwj9m33kpzAidJPvq3cbdnXjaew6oTLqHWrBbZQ@mail.gmail.com>
Date: Tue, 26 Sep 2017 10:30:21 +0200
MIME-Version: 1.0
In-Reply-To: <CAADnVQLmSbLHwj9m33kpzAidJPvq3cbdnXjaew6oTLqHWrBbZQ@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Message-Id: <e1352dbc-8dce-13a5-2235-c9fa1d7964de@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Cc: Paul McKenney <paulmck@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, kirill@shutemov.name, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@kernel.org>, dave@stgolabs.net, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Will Deacon <will.deacon@arm.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, haren@linux.vnet.ibm.com, Anshuman Khandual <khandual@linux.vnet.ibm.com>, npiggin@gmail.com, bsingharora@gmail.com, Tim Chen <tim.c.chen@linux.intel.com>, linuxppc-dev@lists.ozlabs.org, "x86@kernel.org" <x86@kernel.org>

Hi Alexei,

Le 25/09/2017 A  18:27, Alexei Starovoitov a A(C)critA :
> On Mon, Sep 18, 2017 at 12:15 AM, Laurent Dufour
> <ldufour@linux.vnet.ibm.com> wrote:
>> Despite the unprovable lockdep warning raised by Sergey, I didn't get any
>> feedback on this series.
>>
>> Is there a chance to get it moved upstream ?
> 
> what is the status ?

As mentioned by Andrew this lacks review and test, what about your 
Ack/Review/Tested-By ?

> We're eagerly looking forward for this set to land,
> since we have several use cases for tracing that
> will build on top of this set as discussed at Plumbers.

Unfortunately I was not able to attend Plumbers this year, but I'll be 
pleased, as well as the MM mailing readers, to get your feedback and use 
cases of this series.

Thanks,
Laurent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
