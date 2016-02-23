Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id B3E1B82F69
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 21:17:20 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id x65so102909233pfb.1
        for <linux-mm@kvack.org>; Mon, 22 Feb 2016 18:17:20 -0800 (PST)
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com. [32.97.110.150])
        by mx.google.com with ESMTPS id e29si43632434pfb.131.2016.02.22.18.17.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Mon, 22 Feb 2016 18:17:19 -0800 (PST)
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 22 Feb 2016 19:17:19 -0700
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id DB95119D8041
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 19:05:13 -0700 (MST)
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by b03cxnp08027.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1N2HGlU34734162
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 19:17:16 -0700
Received: from d03av01.boulder.ibm.com (localhost [127.0.0.1])
	by d03av01.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1N2HGGw022850
	for <linux-mm@kvack.org>; Mon, 22 Feb 2016 19:17:16 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V2 00/29] Book3s abstraction in preparation for new MMU model
In-Reply-To: <1456192777.2463.131.camel@buserror.net>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <87zivaxbll.fsf@linux.vnet.ibm.com> <1456192777.2463.131.camel@buserror.net>
Date: Tue, 23 Feb 2016 07:47:11 +0530
Message-ID: <87vb5ggogo.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Scott Wood <oss@buserror.net>, benh@kernel.crashing.org, paulus@samba.org, mpe@ellerman.id.au
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org

Scott Wood <oss@buserror.net> writes:

> On Tue, 2016-02-09 at 18:52 +0530, Aneesh Kumar K.V wrote:
>> 
>> Hi Scott,
>> 
>> I missed adding you on CC:, Can you take a look at this and make sure we
>> are not breaking anything on freescale.
>
> I'm having trouble getting it to apply cleanly.  Do you have a git tree I can
> test?
>


https://github.com/kvaneesh/linux/commits/radix-mmu-v2

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
