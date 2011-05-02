Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9DF586B0012
	for <linux-mm@kvack.org>; Mon,  2 May 2011 18:50:20 -0400 (EDT)
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e5.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p42MNmjG018963
	for <linux-mm@kvack.org>; Mon, 2 May 2011 18:23:48 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p42MoIJ1569458
	for <linux-mm@kvack.org>; Mon, 2 May 2011 18:50:18 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p42Io5ni004231
	for <linux-mm@kvack.org>; Mon, 2 May 2011 15:50:07 -0300
Subject: Re: [PATCH 2/4] mm: Enable set_page_section() only if
 CONFIG_SPARSEMEM and !CONFIG_SPARSEMEM_VMEMMAP
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20110502212012.GC4623@router-fw-old.local.net-space.pl>
References: <20110502212012.GC4623@router-fw-old.local.net-space.pl>
Content-Type: text/plain; charset="ISO-8859-1"
Date: Mon, 02 May 2011 15:50:14 -0700
Message-ID: <1304376614.30823.48.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2011-05-02 at 23:20 +0200, Daniel Kiper wrote:
> set_page_section() is valid only in CONFIG_SPARSEMEM and
> !CONFIG_SPARSEMEM_VMEMMAP context. Move it to proper place
> and amend accordingly functions which are using it.

I guess we've been wasting all that time setting section bits in
page->flags that we'll never use.  Looks sane to me.

Acked-by: Dave Hansen <dave@linux.vnet.ibm.com>

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
