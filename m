Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 8F0886B0012
	for <linux-mm@kvack.org>; Tue,  3 May 2011 12:10:21 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e9.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p43FfVEW017315
	for <linux-mm@kvack.org>; Tue, 3 May 2011 11:41:31 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p43GAJIo107138
	for <linux-mm@kvack.org>; Tue, 3 May 2011 12:10:19 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p43GAHh4010481
	for <linux-mm@kvack.org>; Tue, 3 May 2011 13:10:18 -0300
Subject: Re: [PATCH 4/4] mm: Do not define PFN_SECTION_SHIFT if
 !CONFIG_SPARSEMEM
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110502212226.GE4623@router-fw-old.local.net-space.pl>
References: <20110502212226.GE4623@router-fw-old.local.net-space.pl>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Tue, 03 May 2011 09:10:12 -0700
Message-ID: <1304439012.30823.62.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2011-05-02 at 23:22 +0200, Daniel Kiper wrote:
> Do not define PFN_SECTION_SHIFT if !CONFIG_SPARSEMEM.
> 
> Signed-off-by: Daniel Kiper <dkiper@net-space.pl> 

I'd like if this was a bit easier to verify that it didn't break
anything.  Basically, we should probably limit direct use of
PFN_SECTION_SHIFT to inside #ifdefs in headers.

But, if something is truly using this today, it's probably broken.  It's
easy enough to work around if someone hits it, I guess.

Acked-by: Dave Hansen <dave@linux.vnet.ibm.com>

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
