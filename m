Received: from petasus.jf.intel.com (petasus.jf.intel.com [10.7.209.6])
	by hermes.jf.intel.com (8.11.6/8.11.6/d: outer.mc,v 1.48 2002/05/24 00:39:04 root Exp $) with ESMTP id g721WK009915
	for <linux-mm@kvack.org>; Fri, 2 Aug 2002 01:32:20 GMT
Received: from orsmsxvs040.jf.intel.com (orsmsxvs040.jf.intel.com [192.168.65.206])
	by petasus.jf.intel.com (8.11.6/8.11.6/d: inner.mc,v 1.22 2002/05/24 00:38:22 root Exp $) with SMTP id g721Vng00218
	for <linux-mm@kvack.org>; Fri, 2 Aug 2002 01:31:49 GMT
Message-ID: <25282B06EFB8D31198BF00508B66D4FA03EA56B3@fmsmsx114.fm.intel.com>
From: "Seth, Rohit" <rohit.seth@intel.com>
Subject: RE: large page patch
Date: Thu, 1 Aug 2002 18:34:04 -0700 
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "'David S. Miller'" <davem@redhat.com>, akpm@zip.com.au
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Seth, Rohit" <rohit.seth@intel.com>, "Saxena, Sunil" <sunil.saxena@intel.com>, "Mallick, Asit K" <asit.k.mallick@intel.com>
List-ID: <linux-mm.kvack.org>

There is typo in Andrew's mail.  It is not 256K, but it is 256MB.

-----Original Message-----
From: David S. Miller [mailto:davem@redhat.com]
Sent: Thursday, August 01, 2002 6:20 PM
To: akpm@zip.com.au
Cc: linux-kernel@vger.kernel.org; linux-mm@kvack.org;
rohit.seth@intel.com; sunil.saxena@intel.com; asit.k.mallick@intel.com
Subject: Re: large page patch


   From: Andrew Morton <akpm@zip.com.au>
   Date: Thu, 01 Aug 2002 18:26:40 -0700

   "David S. Miller" wrote:
   > This is probably done to increase the likelyhood that 4MB page orders
   > are available.  If we collapse 4MB pages deeper, they are less likely
   > to be broken up because smaller orders would be selected first.
   
   This is leakage from ia64, which supports up to 256k pages.

Ummm, 4MB > 256K and even with a 4K PAGE_SIZE MAX_ORDER coalesces
up to 4MB already :-)
   
   Apparently a page-table based representation could not be used by PPC.
   
The page-table is just an abstraction, there is no reason dummy
"large" ptes could not be used which are just ignored by the HW TLB
reload code.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
