Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx199.postini.com [74.125.245.199])
	by kanga.kvack.org (Postfix) with SMTP id 7D8566B0006
	for <linux-mm@kvack.org>; Sat, 23 Feb 2013 11:18:08 -0500 (EST)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sun, 24 Feb 2013 02:13:24 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 24AD92CE802D
	for <linux-mm@kvack.org>; Sun, 24 Feb 2013 03:18:01 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1NG5aQ59634260
	for <linux-mm@kvack.org>; Sun, 24 Feb 2013 03:05:37 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1NGHxRU024382
	for <linux-mm@kvack.org>; Sun, 24 Feb 2013 03:17:59 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH -V2 03/21] powerpc: Don't hard code the size of pte page
In-Reply-To: <20130222050607.GC6139@drongo>
References: <1361465248-10867-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1361465248-10867-4-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130222050607.GC6139@drongo>
Date: Sat, 23 Feb 2013 21:47:57 +0530
Message-ID: <87621jc8cq.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: benh@kernel.crashing.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Paul Mackerras <paulus@samba.org> writes:

> On Thu, Feb 21, 2013 at 10:17:10PM +0530, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> USE PTRS_PER_PTE to indicate the size of pte page.
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>> powerpc: Don't hard code the size of pte page
>> 
>> USE PTRS_PER_PTE to indicate the size of pte page.
>> 
>> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
>
> Description and signoff are duplicated.  Description could be more
> informative, for example - why would we want to do this?
>
>> +/*
>> + * hidx is in the second half of the page table. We use the
>> + * 8 bytes per each pte entry.
>
> The casual reader probably wouldn't know what "hidx" is.  The comment
> needs at least to use a better name than "hidx".

how about

+/*
+ * We save the slot number & secondary bit in the second half of the
+ * PTE page. We use the 8 bytes per each pte entry.
+ */


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
