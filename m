Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 509956B0062
	for <linux-mm@kvack.org>; Sat,  9 Jun 2012 09:17:25 -0400 (EDT)
Received: from /spool/local
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Sat, 9 Jun 2012 18:47:22 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q59DHKLF6619540
	for <linux-mm@kvack.org>; Sat, 9 Jun 2012 18:47:20 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q59IkZ7D013050
	for <linux-mm@kvack.org>; Sun, 10 Jun 2012 04:46:36 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH -V8 02/16] hugetlb: don't use ERR_PTR with VM_FAULT* values
In-Reply-To: <20120609111010.GA16034@localhost.localdomain>
References: <1339232401-14392-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1339232401-14392-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <20120609111010.GA16034@localhost.localdomain>User-Agent: Notmuch/0.11.1+346~g13d19c3 (http://notmuchmail.org) Emacs/23.3.1 (x86_64-pc-linux-gnu)
Date: Sat, 09 Jun 2012 18:47:14 +0530
Message-ID: <87mx4clj51.fsf@skywalker.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad@darnok.org>
Cc: linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, dhillf@gmail.com, rientjes@google.com, mhocko@suse.cz, akpm@linux-foundation.org, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, cgroups@vger.kernel.org

Konrad Rzeszutek Wilk <konrad@darnok.org> writes:

> On Sat, Jun 09, 2012 at 02:29:47PM +0530, Aneesh Kumar K.V wrote:
>> From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
>> 
>> The current use of VM_FAULT_* codes with ERR_PTR requires us to ensure
>> VM_FAULT_* values will not exceed MAX_ERRNO value. Decouple the
>> VM_FAULT_* values from MAX_ERRNO.
>
> I see you using the -ENOMEM|-ENOSPC, but I don't see any reference in the
> code to MAX_ERRNO? Can you provide a comment explaining in a tad little
> bit about the interaction of MAX_ERRNO and VM_FAULT?

That comes from this 

#define IS_ERR_VALUE(x) unlikely((x) >= (unsigned long)-MAX_ERRNO)


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
