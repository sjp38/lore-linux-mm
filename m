Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com [209.85.220.178])
	by kanga.kvack.org (Postfix) with ESMTP id 8C6CD6B0005
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 03:25:46 -0500 (EST)
Received: by mail-qk0-f178.google.com with SMTP id s68so64034568qkh.3
        for <linux-mm@kvack.org>; Tue, 16 Feb 2016 00:25:46 -0800 (PST)
Received: from e36.co.us.ibm.com (e36.co.us.ibm.com. [32.97.110.154])
        by mx.google.com with ESMTPS id d77si39435601qkb.20.2016.02.16.00.25.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 16 Feb 2016 00:25:46 -0800 (PST)
Received: from localhost
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 16 Feb 2016 01:25:44 -0700
Received: from b03cxnp07028.gho.boulder.ibm.com (b03cxnp07028.gho.boulder.ibm.com [9.17.130.15])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 176F71FF0023
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 01:13:51 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by b03cxnp07028.gho.boulder.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u1G8PfTd26542150
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 01:25:41 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u1G8PeRY006062
	for <linux-mm@kvack.org>; Tue, 16 Feb 2016 01:25:40 -0700
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH V2 12/29] powerpc/mm: Move hash64 specific defintions to seperate header
In-Reply-To: <20160215052449.GE3797@oak.ozlabs.ibm.com>
References: <1454923241-6681-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1454923241-6681-13-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20160215052449.GE3797@oak.ozlabs.ibm.com>
Date: Tue, 16 Feb 2016 13:55:31 +0530
Message-ID: <87y4aldptw.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@ozlabs.org>
Cc: benh@kernel.crashing.org, mpe@ellerman.id.au, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Paul Mackerras <paulus@ozlabs.org> writes:

> On Mon, Feb 08, 2016 at 02:50:24PM +0530, Aneesh Kumar K.V wrote:
>> Also split pgalloc 64k and 4k headers
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>
> In the subject: s/defintions/definitions/; s/seperate/separate/
>
> A more detailed patch description would be good.  Apart from that,
>
> Reviewed-by: Paul Mackerras <paulus@samba.org>

Updated as below:

powerpc/mm: Move hash64 specific definitions to separate header

We will be adding a radix variant of these routines in the followup
patches. Move the hash64 variant into its own header so that we can
rename them easily later. Also split pgalloc 64k and 4k headers

Reviewed-by: Paul Mackerras <paulus@samba.org>
Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
