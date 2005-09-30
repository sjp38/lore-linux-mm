Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8UF7hP3007203
	for <linux-mm@kvack.org>; Fri, 30 Sep 2005 11:07:43 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8UF9t8P301744
	for <linux-mm@kvack.org>; Fri, 30 Sep 2005 09:09:59 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j8UF9GKR027868
	for <linux-mm@kvack.org>; Fri, 30 Sep 2005 09:09:16 -0600
Subject: Re: [PATCH]Remove pgdat list ver.2 [1/2]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20050930205919.7019.Y-GOTO@jp.fujitsu.com>
References: <20050930205919.7019.Y-GOTO@jp.fujitsu.com>
Content-Type: text/plain
Date: Fri, 30 Sep 2005 08:09:14 -0700
Message-Id: <1128092954.6145.12.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, ia64 list <linux-ia64@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2005-09-30 at 22:07 +0900, Yasunori Goto wrote:
> I updated patches to remove pgdat link. They are for 2.6.14-rc2.
> Please include this in your -mhp patch set.

Looks very nice.  I'll pull them in.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
