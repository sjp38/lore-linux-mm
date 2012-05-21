Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx111.postini.com [74.125.245.111])
	by kanga.kvack.org (Postfix) with SMTP id 6BD756B00F6
	for <linux-mm@kvack.org>; Mon, 21 May 2012 16:35:15 -0400 (EDT)
Received: from /spool/local
	by e6.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Mon, 21 May 2012 16:35:11 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 86CEF6E8049
	for <linux-mm@kvack.org>; Mon, 21 May 2012 16:34:33 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q4LKYXbb066126
	for <linux-mm@kvack.org>; Mon, 21 May 2012 16:34:33 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q4LKYXjj015304
	for <linux-mm@kvack.org>; Mon, 21 May 2012 16:34:33 -0400
Message-ID: <4FBAA6D7.2000604@linux.vnet.ibm.com>
Date: Mon, 21 May 2012 13:34:31 -0700
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 1/2] hugetlb: fix resv_map leak in error path
References: <20120521203022.F7FCE507@kernel>
In-Reply-To: <20120521203022.F7FCE507@kernel>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 05/21/2012 01:30 PM, Dave Hansen wrote:
> When called for anonymous (non-shared) mappings,
> hugetlb_reserve_pages() does a resv_map_alloc().  It depends on
> code in hugetlbfs's vm_ops->close() to release that allocation.

Sorry, this one escaped unintentionally!  This patch itself is good, but
I didn't mean to send it along with 2/2.  Disregard this 1/2, but please
take a look at 2/2!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
