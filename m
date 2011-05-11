Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 850E96B0023
	for <linux-mm@kvack.org>; Wed, 11 May 2011 19:10:28 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id p4BNAPMp017115
	for <linux-mm@kvack.org>; Wed, 11 May 2011 16:10:25 -0700
Received: from pxi6 (pxi6.prod.google.com [10.243.27.6])
	by kpbe12.cbf.corp.google.com with ESMTP id p4BN9ajg022650
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 11 May 2011 16:10:22 -0700
Received: by pxi6 with SMTP id 6so633574pxi.31
        for <linux-mm@kvack.org>; Wed, 11 May 2011 16:10:22 -0700 (PDT)
Date: Wed, 11 May 2011 16:10:20 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 2/4] mm: Enable set_page_section() only if CONFIG_SPARSEMEM
 and !CONFIG_SPARSEMEM_VMEMMAP
In-Reply-To: <20110502212012.GC4623@router-fw-old.local.net-space.pl>
Message-ID: <alpine.DEB.2.00.1105111605050.24003@chino.kir.corp.google.com>
References: <20110502212012.GC4623@router-fw-old.local.net-space.pl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2 May 2011, Daniel Kiper wrote:

> set_page_section() is valid only in CONFIG_SPARSEMEM and
> !CONFIG_SPARSEMEM_VMEMMAP context.

s/valid/needed/.  set_page_section() _is_ valid in all contexts since 
SECTIONS_MASK and SECTIONS_PGSHIFT is defined in all contexts.  

> Move it to proper place
> and amend accordingly functions which are using it.
> 
> Signed-off-by: Daniel Kiper <dkiper@net-space.pl>

After the changelog is fixed:

	Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
