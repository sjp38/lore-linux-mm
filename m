Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m1QGmv0j009909
	for <linux-mm@kvack.org>; Tue, 26 Feb 2008 11:48:57 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m1QGmvXK253600
	for <linux-mm@kvack.org>; Tue, 26 Feb 2008 11:48:57 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m1QGmujq018502
	for <linux-mm@kvack.org>; Tue, 26 Feb 2008 11:48:57 -0500
Subject: Re: [PATCH 1/3] hugetlb: Correct page count for surplus huge pages
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1204044815.3837.45.camel@localhost.localdomain>
References: <20080225220119.23627.33676.stgit@kernel>
	 <20080225220129.23627.5152.stgit@kernel>
	 <1203978363.11846.10.camel@nimitz.home.sr71.net>
	 <1203980580.3837.30.camel@localhost.localdomain>
	 <1203981109.11846.22.camel@nimitz.home.sr71.net>
	 <1204044815.3837.45.camel@localhost.localdomain>
Content-Type: text/plain
Date: Tue, 26 Feb 2008 08:48:54 -0800
Message-Id: <1204044534.1228.0.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Adam Litke <agl@us.ibm.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, apw@shadowen.org, nacc@linux.vnet.ibm.com, agl@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, 2008-02-26 at 10:53 -0600, Adam Litke wrote:
> This is an interesting idea and I will think about it some more.
> However, switching this around will introduce more of the churn that
> makes people nervous.

Touche!

> So I would appeal that we put forth my original
> idea (with your suggested modification) because it is a simple and
> verifiable bug fix.

Looks good, thanks Adam.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
