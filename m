Received: from westrelay01.boulder.ibm.com (westrelay01.boulder.ibm.com [9.17.195.10])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j1I5GkLg244726
	for <linux-mm@kvack.org>; Fri, 18 Feb 2005 00:16:46 -0500
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay01.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j1I5GkXt135816
	for <linux-mm@kvack.org>; Thu, 17 Feb 2005 22:16:46 -0700
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11/8.12.11) with ESMTP id j1I5Gj1u000505
	for <linux-mm@kvack.org>; Thu, 17 Feb 2005 22:16:46 -0700
Date: Thu, 17 Feb 2005 21:16:33 -0800
From: Mike Kravetz <kravetz@us.ibm.com>
Subject: Re: [RFC][PATCH] Sparse Memory Handling (hot-add foundation)
Message-ID: <20050218051633.GA5037@w-mikek2.ibm.com>
References: <1108685033.6482.38.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1108685033.6482.38.camel@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, lhms <lhms-devel@lists.sourceforge.net>, linux-mm <linux-mm@kvack.org>, Andy Whitcroft <apw@shadowen.org>
List-ID: <linux-mm.kvack.org>

On Thu, Feb 17, 2005 at 04:03:53PM -0800, Dave Hansen wrote:
> The attached patch

Just tried to compile this and noticed that there is no definition
of valid_section_nr(),  referenced in sparse_init.

-- 
Mike
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
