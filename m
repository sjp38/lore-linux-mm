Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e32.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id k29Iefse021116
	for <linux-mm@kvack.org>; Thu, 9 Mar 2006 13:40:41 -0500
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VER6.8) with ESMTP id k29IhSqe121526
	for <linux-mm@kvack.org>; Thu, 9 Mar 2006 11:43:29 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id k29IeaSa013598
	for <linux-mm@kvack.org>; Thu, 9 Mar 2006 11:40:37 -0700
Subject: Re: [PATCH/RFC] Migrate-on-fault prototype 1/5 V0.1 - separate
	unmap from radix tree replace
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1141928931.6393.11.camel@localhost.localdomain>
References: <1141928931.6393.11.camel@localhost.localdomain>
Content-Type: text/plain
Date: Thu, 09 Mar 2006 10:40:12 -0800
Message-Id: <1141929612.8599.145.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: lee.schermerhorn@hp.com
Cc: linux-mm <linux-mm@kvack.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2006-03-09 at 13:28 -0500, Lee Schermerhorn wrote:
> @@ -3083,7 +3084,7 @@ int buffer_migrate_page(struct page *new
> ClearPagePrivate(page);
> set_page_private(newpage, page_private(page));
> set_page_private(page, 0);
> - put_page(page);
> + put_page(page); /* transfer buf ref to newpage */
> get_page(newpage); 

Is it just me, or do these have some serious whitespace borkage?

Do you have a clean version of them posted anywhere?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
