Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com [9.17.195.11])
	by e35.co.us.ibm.com (8.12.10/8.12.9) with ESMTP id j5UJTtOM535622
	for <linux-mm@kvack.org>; Thu, 30 Jun 2005 15:29:55 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by westrelay02.boulder.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id j5UJTtIr304462
	for <linux-mm@kvack.org>; Thu, 30 Jun 2005 13:29:55 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11/8.13.3) with ESMTP id j5UJTsDQ027188
	for <linux-mm@kvack.org>; Thu, 30 Jun 2005 13:29:54 -0600
Subject: Re: [ckrm-tech] [PATCH 4/6] CKRM: Add guarantee support for mem
	controller
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <1120159282.14910.60.camel@linuxchandra>
References: <1119651942.5105.21.camel@linuxchandra>
	 <1120110730.479552.4689.nullmailer@yamt.dyndns.org>
	 <1120155104.14910.36.camel@linuxchandra>
	 <1120155826.12143.61.camel@localhost>
	 <1120157624.14910.42.camel@linuxchandra>
	 <1120158124.12143.68.camel@localhost>
	 <1120159282.14910.60.camel@linuxchandra>
Content-Type: text/plain
Date: Thu, 30 Jun 2005 12:29:37 -0700
Message-Id: <1120159777.12143.74.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chandra S. Seetharaman [imap]" <sekharan@us.ibm.com>
Cc: YAMAMOTO Takashi <yamamoto@valinux.co.jp>, ckrm-tech@lists.sourceforge.net, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2005-06-30 at 12:21 -0700, Chandra Seetharaman wrote:
> Hmm.... either you are looking at a old set of patches or you do not
> have all the patches in the current set. ckrm_clear_page_class is _not_
> from free_pages_bulk in the current patchset fully applied :).

I was looking at the patches individually.

> chandra
> PS: it should not be there in any of the patches in the current
> patchset, but is left out due to code rearrangements, I will fix that.

I find the whole patch set really hard to understand.  It seems more
like a linear set of how you wrote it and fixed it, rather than broken
up into logical components.

For instance, what does "Add guarantee support for mem-controller" have
to do with removing ckrm_clear_page_class() from the allocator path?

If there was a reason that you remove that function from
__free_pages_bulk(), because of a bug fix, it needs to go into a
separate patch.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
