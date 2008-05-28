Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4SKciq5031788
	for <linux-mm@kvack.org>; Wed, 28 May 2008 16:38:44 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4SKcieQ150470
	for <linux-mm@kvack.org>; Wed, 28 May 2008 16:38:44 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4SKch4x010631
	for <linux-mm@kvack.org>; Wed, 28 May 2008 16:38:44 -0400
Subject: Re: [PATCH 2/3] hugetlb-move-reservation-region-support-earlier
From: Adam Litke <agl@us.ibm.com>
In-Reply-To: <1211929796.0@pinky>
References: <exportbomb.1211929624@pinky>  <1211929796.0@pinky>
Content-Type: text/plain
Date: Wed, 28 May 2008 15:38:44 -0500
Message-Id: <1212007124.12036.67.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andy Whitcroft <apw@shadowen.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, wli@holomorphy.com, kenchen@google.com, dwg@au1.ibm.com, andi@firstfloor.org, Mel Gorman <mel@csn.ul.ie>, dean@arctic.org, abh@cray.com
List-ID: <linux-mm.kvack.org>

On Wed, 2008-05-28 at 00:09 +0100, Andy Whitcroft wrote:
> The following patch will require use of the reservation regions support.
> Move this earlier in the file.  No changes have been made to this code.
> 
> Signed-off-by: Andy Whitcroft <apw@shadowen.org>

Acked-by: Adam Litke <agl@us.ibm.com>

-- 
Adam Litke - (agl at us.ibm.com)
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
