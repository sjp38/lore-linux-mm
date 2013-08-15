Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 2EE5E6B003C
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 15:34:06 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC PATCH] Fix aio performance regression for database caused by THP
References: <1376590389.24607.33.camel@concerto>
Date: Thu, 15 Aug 2013 12:34:05 -0700
In-Reply-To: <1376590389.24607.33.camel@concerto> (Khalid Aziz's message of
	"Thu, 15 Aug 2013 12:13:09 -0600")
Message-ID: <8738qakatu.fsf@tassilo.jf.intel.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Khalid Aziz <khalid.aziz@oracle.com>
Cc: aarcange@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, mgorman@suse.de, riel@redhat.com, minchan@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Khalid Aziz <khalid.aziz@oracle.com> writes:

> I am working with a tool that simulates oracle database I/O workload.
> This tool (orion to be specific -
> <http://docs.oracle.com/cd/E11882_01/server.112/e16638/iodesign.htm#autoId24>)
> allocates hugetlbfs pages using shmget() with SHM_HUGETLB flag. 

Is this tool available for download?

I would rather prefer to address the locking overhead in THP too.

The fundamental problem is that we have to touch all the pages?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
