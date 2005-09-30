Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j8UG3BJd008080
	for <linux-mm@kvack.org>; Fri, 30 Sep 2005 12:03:11 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j8UG3Bon078982
	for <linux-mm@kvack.org>; Fri, 30 Sep 2005 12:03:11 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j8UG3BtE005662
	for <linux-mm@kvack.org>; Fri, 30 Sep 2005 12:03:11 -0400
Subject: Re: [PATCH]Remove pgdat list ver.2 [1/2]
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1128092954.6145.12.camel@localhost>
References: <20050930205919.7019.Y-GOTO@jp.fujitsu.com>
	 <1128092954.6145.12.camel@localhost>
Content-Type: text/plain
Date: Fri, 30 Sep 2005 09:03:08 -0700
Message-Id: <1128096188.6145.34.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yasunori Goto <y-goto@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, ia64 list <linux-ia64@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2005-09-30 at 08:09 -0700, Dave Hansen wrote:
> On Fri, 2005-09-30 at 22:07 +0900, Yasunori Goto wrote:
> > I updated patches to remove pgdat link. They are for 2.6.14-rc2.
> > Please include this in your -mhp patch set.
> 
> Looks very nice.  I'll pull them in.

I spoke too soon :)

linux/mmzone.h uses the !NUMA NODE_DATA() before it is declared.  I'm
seeing if I can work around it now.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
