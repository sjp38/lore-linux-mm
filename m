Received: from westrelay03.boulder.ibm.com (westrelay03.boulder.ibm.com [9.17.195.12])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j2PI3JLg310576
	for <linux-mm@kvack.org>; Fri, 25 Mar 2005 13:03:19 -0500
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay03.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j2PI3JVl166654
	for <linux-mm@kvack.org>; Fri, 25 Mar 2005 11:03:19 -0700
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j2PI3IQ0018293
	for <linux-mm@kvack.org>; Fri, 25 Mar 2005 11:03:18 -0700
Subject: Re: patch to remove warning in 2.6.11 + Hirokazu's page migration
	patches
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <424452F2.7080206@engr.sgi.com>
References: <424452F2.7080206@engr.sgi.com>
Content-Type: text/plain
Date: Fri, 25 Mar 2005 10:03:17 -0800
Message-Id: <1111773797.9691.14.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@engr.sgi.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Marcello Tosatti <marcelo.tosatti@cyclades.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2005-03-25 at 12:05 -0600, Ray Bryant wrote:
> Hirokazu,
> 
> The attached patch fixes a minor problem with your 2.6.11 page migration
> patches.

Looks fine to me.  Hirokazu, I'll pick this up, unless you see any
problems with it.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
