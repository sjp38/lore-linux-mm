Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lATHlrPj006348
	for <linux-mm@kvack.org>; Thu, 29 Nov 2007 12:47:53 -0500
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lATHlYCI128902
	for <linux-mm@kvack.org>; Thu, 29 Nov 2007 12:47:53 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lATHlYKT030878
	for <linux-mm@kvack.org>; Thu, 29 Nov 2007 12:47:34 -0500
Subject: Re: [Patch](Resend) mm/sparse.c: Improve the error handling for
	sparse_add_one_section()
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071128124420.GJ2464@hacking>
References: <1195507022.27759.146.camel@localhost>
	 <20071123055150.GA2488@hacking> <20071126191316.99CF.Y-GOTO@jp.fujitsu.com>
	 <20071127022609.GA4164@hacking> <1196189625.5764.36.camel@localhost>
	 <20071128124420.GJ2464@hacking>
Content-Type: text/plain
Date: Thu, 29 Nov 2007 09:47:30 -0800
Message-Id: <1196358450.18851.72.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: WANG Cong <xiyou.wangcong@gmail.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, Rik van Riel <riel@redhat.com>, Christoph Lameter <clameter@sgi.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

This looks fine now.

Acked-by: Dave Hansen <haveblue@us.ibm.com> 

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
