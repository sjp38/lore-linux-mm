Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id A57016B0023
	for <linux-mm@kvack.org>; Wed, 11 May 2011 18:48:16 -0400 (EDT)
Received: from hpaq3.eem.corp.google.com (hpaq3.eem.corp.google.com [172.25.149.3])
	by smtp-out.google.com with ESMTP id p4BMlxso007713
	for <linux-mm@kvack.org>; Wed, 11 May 2011 15:47:59 -0700
Received: from pvg13 (pvg13.prod.google.com [10.241.210.141])
	by hpaq3.eem.corp.google.com with ESMTP id p4BMlpTA030369
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 11 May 2011 15:47:52 -0700
Received: by pvg13 with SMTP id 13so591993pvg.12
        for <linux-mm@kvack.org>; Wed, 11 May 2011 15:47:50 -0700 (PDT)
Date: Wed, 11 May 2011 15:47:49 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/4] mm: Remove dependency on CONFIG_FLATMEM from
 online_page()
In-Reply-To: <20110502211915.GB4623@router-fw-old.local.net-space.pl>
Message-ID: <alpine.DEB.2.00.1105111547160.24003@chino.kir.corp.google.com>
References: <20110502211915.GB4623@router-fw-old.local.net-space.pl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2 May 2011, Daniel Kiper wrote:

> Memory hotplug code strictly depends on CONFIG_SPARSEMEM.
> It means that code depending on CONFIG_FLATMEM in online_page()
> is never compiled. Remove it because it is not needed anymore.
> 
> Signed-off-by: Daniel Kiper <dkiper@net-space.pl>

The code you're patching depends on CONFIG_MEMORY_HOTPLUG_SPARSE, so this 
is valid.  The changelog should be updated to reflect that, however.

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
