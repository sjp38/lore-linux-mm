Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1F3556B004D
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 20:46:07 -0400 (EDT)
Message-ID: <4A84B3F0.80009@oracle.com>
Date: Thu, 13 Aug 2009 17:46:40 -0700
From: Randy Dunlap <randy.dunlap@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/3] Add MAP_HUGETLB example to vm/hugetlbpage.txt V2
References: <cover.1250156841.git.ebmunson@us.ibm.com> <e9b02974a0cca308927ff3a4a0765b93faa6d12f.1250156841.git.ebmunson@us.ibm.com> <83949d066e2a7221a25dd74d12d6dcf7e8b4e9ba.1250156841.git.ebmunson@us.ibm.com> <617054c59f53f43f6fecfd6908cfb86ea1dd6f72.1250156841.git.ebmunson@us.ibm.com> <alpine.DEB.2.00.0908131449270.9805@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.0908131449270.9805@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: Eric B Munson <ebmunson@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-man@vger.kernel.org, akpm@linux-foundation.org, mtk.manpages@gmail.com
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:
> On Thu, 13 Aug 2009, Eric B Munson wrote:
> 
>> This patch adds an example of how to use the MAP_HUGETLB flag to
>> the vm documentation.
>>
>> Signed-off-by: Eric B Munson <ebmunson@us.ibm.com>
>> ---
>> Changes from V1:
>>  Rebase to newest linux-2.6 tree
>>  Change MAP_LARGEPAGE to MAP_HUGETLB to match flag name in huge page shm
>>
>>  Documentation/vm/hugetlbpage.txt |   80 ++++++++++++++++++++++++++++++++++++++
>>  1 files changed, 80 insertions(+), 0 deletions(-)
>>
>> diff --git a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbpage.txt
>> index ea8714f..d30fa1a 100644
>> --- a/Documentation/vm/hugetlbpage.txt
>> +++ b/Documentation/vm/hugetlbpage.txt
>> @@ -337,3 +337,83 @@ int main(void)
>>  
>>  	return 0;
>>  }
>> +
>> +*******************************************************************
>> +
>> +/*
>> + * Example of using hugepage memory in a user application using the mmap
>> + * system call with MAP_LARGEPAGE flag.  Before running this program make
> 
> s/MAP_LARGEPAGE/MAP_HUGETLB/

I'm (slowly) making source code examples in Documentation/ buildable,
as this one should be, please.

I.e., put it in a separate source file (hugetlbpage.txt can refer to the
source file if you want it to) and add a Makefile similar to other
Makefiles in the Documentation/ tree.

~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
