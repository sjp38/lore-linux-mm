Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 283F66B0006
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 06:03:01 -0500 (EST)
Received: from /spool/local
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Mon, 4 Mar 2013 20:57:01 +1000
Received: from d23relay03.au.ibm.com (d23relay03.au.ibm.com [9.190.235.21])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id A5A3F357802D
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 22:02:27 +1100 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay03.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r24B2O3t52494346
	for <linux-mm@kvack.org>; Mon, 4 Mar 2013 22:02:24 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r24B2R7D030040
	for <linux-mm@kvack.org>; Mon, 4 Mar 2013 22:02:27 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V1 07/24] powerpc: Add size argument to pgtable_cache_add
In-Reply-To: <20130304051340.GC27523@drongo>
References: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1361865914-13911-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20130304051340.GC27523@drongo>
Date: Mon, 04 Mar 2013 16:32:24 +0530
Message-ID: <871ubv2zsv.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: benh@kernel.crashing.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Paul Mackerras <paulus@samba.org> writes:

> On Tue, Feb 26, 2013 at 01:34:57PM +0530, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> We will use this later with THP changes to request for pmd table of double the size.
>> THP code does PTE page allocation along with large page request and deposit them
>> for later use. This is to ensure that we won't have any failures when we split
>> huge pages to regular pages.
>> 
>> On powerpc we want to use the deposited PTE page for storing hash pte slot and
>> secondary bit information for the HPTEs. Hence we save them in the second half
>> of the pmd table.
>
> Looks OK, but you should explain why you made the wholesale change of
> "shift" to "index".  Is there some important semantic difference, or
> do you just prefer the "index" name for some reason?
>

Now with table_size argument, the first arg is no more the shift value,
rather it is index into the array. Hence i changed the variable name. I
will split that patch to make it easy for review.

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
