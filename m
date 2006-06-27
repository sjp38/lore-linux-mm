Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id k5RIjdOV010717
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=FAIL)
	for <linux-mm@kvack.org>; Tue, 27 Jun 2006 14:45:39 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/NCO/VER7.0) with ESMTP id k5RIjsan186436
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Tue, 27 Jun 2006 12:45:54 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k5RIjcuZ007210
	for <linux-mm@kvack.org>; Tue, 27 Jun 2006 12:45:38 -0600
Subject: Re: slow hugetlb from 2.6.15
From: Badari Pulavarty <pbadari@gmail.com>
In-Reply-To: <20060627182325.GE6380@blackhole.websupport.sk>
References: <20060627182325.GE6380@blackhole.websupport.sk>
Content-Type: text/plain
Date: Tue, 27 Jun 2006 11:47:37 -0700
Message-Id: <1151434062.8918.7.camel@dyn9047017100.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: stanojr@blackhole.websupport.sk
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2006-06-27 at 20:23 +0200, stanojr@blackhole.websupport.sk
wrote:
> hello
> 
> look at this benchmark http://www-unix.mcs.anl.gov/~kazutomo/hugepage/note.html
> i try benchmark it on latest 2.6.17.1 (x86 and x86_64) and it slow like 2.6.16 on that web
> (in comparing to standard 4kb page)
> its feature or bug ? 

Most likely, its due to new feature - demand paging for large pages :)
Doing mlock() on mmaped area help ?

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
