Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e35.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m7F02cXk030580
	for <linux-mm@kvack.org>; Thu, 14 Aug 2008 20:02:38 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m7F02b4l177938
	for <linux-mm@kvack.org>; Thu, 14 Aug 2008 18:02:37 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m7F02bLR025803
	for <linux-mm@kvack.org>; Thu, 14 Aug 2008 18:02:37 -0600
Subject: Re: sparsemem support for mips with highmem
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <48A4C542.5000308@sciatl.com>
References: <48A4AC39.7020707@sciatl.com> <1218753308.23641.56.camel@nimitz>
	 <48A4C542.5000308@sciatl.com>
Content-Type: text/plain
Date: Thu, 14 Aug 2008 17:02:35 -0700
Message-Id: <1218758555.23641.69.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: C Michael Sundius <Michael.sundius@sciatl.com>
Cc: linux-mm@kvack.org, linux-mips@linux-mips.org, jfraser@broadcom.com, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

Looks great to me.  I can't test it, of course, but I don't see any
problems with it.

Signed-off-by: Dave Hansen <dave@linux.vnet.ibm.com>

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
