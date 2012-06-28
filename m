Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 8635B6B005A
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 11:09:03 -0400 (EDT)
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Thu, 28 Jun 2012 11:09:02 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 988BC6E965C
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 10:54:19 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q5SEsIlR61014116
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 10:54:18 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q5SEsHrT010639
	for <linux-mm@kvack.org>; Thu, 28 Jun 2012 10:54:17 -0400
Message-ID: <4FEC700A.6090205@linux.vnet.ibm.com>
Date: Thu, 28 Jun 2012 07:54:02 -0700
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 2/3] mm/sparse: fix possible memory leak
References: <1340814968-2948-1-git-send-email-shangw@linux.vnet.ibm.com> <1340814968-2948-2-git-send-email-shangw@linux.vnet.ibm.com> <4FEB3C67.6070604@linux.vnet.ibm.com> <20120628060330.GA26576@shangw>
In-Reply-To: <20120628060330.GA26576@shangw>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gavin Shan <shangw@linux.vnet.ibm.com>
Cc: linux-mm@kvack.org, mhocko@suse.cz, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org

On 06/27/2012 11:03 PM, Gavin Shan wrote:
>> >Gavin, have you actually tested this in some way?  It looks OK to me,
>> >but I worry that you've just added a block of code that's exceedingly
>> >unlikely to get run.
> I didn't test this and I just catch the point while reading the source
> code. By the way, I would like to know the popular utilities used for
> memory testing. If you can share some information regarding that, that
> would be great.
> 
> 	- memory related benchmark testing utility.
> 	- some documents on Linux memory testing.

This patch is intended to fix a memory leak in the case of a race.  Can
you _actually_ make it race to ensure that things work properly?  If
not, can you add something like a sleep() to _force_ it to race?

Or, have you simply run your code a couple of times like this, both for
the bootmem and slab cases:

	int nid = 0;
	for (i=0; i < something; i++) {
		section = sparse_index_alloc(nid);
		sparse_index_free(section, nid);
	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
