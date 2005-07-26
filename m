Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j6QL627K051154
	for <linux-mm@kvack.org>; Tue, 26 Jul 2005 17:06:02 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j6QL64uN177114
	for <linux-mm@kvack.org>; Tue, 26 Jul 2005 15:06:04 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j6QL61BV030159
	for <linux-mm@kvack.org>; Tue, 26 Jul 2005 15:06:01 -0600
Subject: Re: Memory pressure handling with iSCSI
From: Badari Pulavarty <pbadari@us.ibm.com>
In-Reply-To: <Pine.LNX.4.61.0507261659250.1786@chimarrao.boston.redhat.com>
References: <1122399331.6433.29.camel@dyn9047017102.beaverton.ibm.com>
	 <Pine.LNX.4.61.0507261659250.1786@chimarrao.boston.redhat.com>
Content-Type: text/plain
Date: Tue, 26 Jul 2005 14:05:49 -0700
Message-Id: <1122411949.6433.50.camel@dyn9047017102.beaverton.ibm.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
List-ID: <linux-mm.kvack.org>

On Tue, 2005-07-26 at 16:59 -0400, Rik van Riel wrote:
> On Tue, 26 Jul 2005, Badari Pulavarty wrote:
> 
> > After KS & OLS discussions about memory pressure, I wanted to re-do
> > iSCSI testing with "dd"s to see if we are throttling writes.  
> 
> Could you also try with shared writable mmap, to see if that
> works ok or triggers a deadlock ?


I can, but lets finish addressing one issue at a time. Last time,
I changed too many things at the same time and got no where :(

Thanks,
Badari

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
