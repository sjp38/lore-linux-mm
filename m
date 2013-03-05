Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id DE3696B0006
	for <linux-mm@kvack.org>; Mon,  4 Mar 2013 21:12:29 -0500 (EST)
Date: Tue, 5 Mar 2013 12:50:41 +1100
From: Paul Mackerras <paulus@samba.org>
Subject: Re: [PATCH -V1 07/24] powerpc: Add size argument to pgtable_cache_add
Message-ID: <20130305015041.GA2888@iris.ozlabs.ibm.com>
References: <1361865914-13911-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <1361865914-13911-8-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
 <20130304051340.GC27523@drongo>
 <871ubv2zsv.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <871ubv2zsv.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: benh@kernel.crashing.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

On Mon, Mar 04, 2013 at 04:32:24PM +0530, Aneesh Kumar K.V wrote:
> 
> Now with table_size argument, the first arg is no more the shift value,
> rather it is index into the array. Hence i changed the variable name. I
> will split that patch to make it easy for review.

OK, so you're saying that the simple relation between index and the
size of the objects in PGT_CACHE(index) no longer holds.  That worries
me, because now, what guarantees that two callers won't use the same
index value with two different sizes?  And what guarantees that we
won't have two callers using different index values but the same size
(which wouldn't be a disaster but would be a waste of space)?

I think it would be preferable to keep the relation between shift and
the size of the objects and just arrange to use a different shift
value for the pmd objects when you need to.

Paul.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
