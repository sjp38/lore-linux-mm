Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lAUIVguC030320
	for <linux-mm@kvack.org>; Fri, 30 Nov 2007 13:31:42 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lAUIVa5m1302710
	for <linux-mm@kvack.org>; Fri, 30 Nov 2007 13:31:37 -0500
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lAUIVXVZ004987
	for <linux-mm@kvack.org>; Fri, 30 Nov 2007 11:31:33 -0700
Subject: Re: [PATCH] mm: fix confusing __GFP_REPEAT related comments
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071130174307.GS13444@us.ibm.com>
References: <20071129214828.GD20882@us.ibm.com>
	 <1196378080.18851.116.camel@localhost> <20071130041922.GQ13444@us.ibm.com>
	 <1196447260.19681.8.camel@localhost>  <20071130174307.GS13444@us.ibm.com>
Content-Type: text/plain
Date: Fri, 30 Nov 2007 10:31:30 -0800
Message-Id: <1196447490.19681.10.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: akpm@linux-foundation.org, mel@skynet.ie, wli@holomorphy.com, apw@shadowen.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 2007-11-30 at 09:43 -0800, Nishanth Aravamudan wrote:
> 
> But those are of course only the explicit callers -- there are
> presumably many others that are getting the same effect by passing a low
> order. 

Yeah, and the socket function is just a helper and will have a number of
users.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
