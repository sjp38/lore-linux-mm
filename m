Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 253358D0040
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 18:42:02 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p2SMfwem025208
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 15:41:58 -0700
Received: from pwi15 (pwi15.prod.google.com [10.241.219.15])
	by wpaz21.hot.corp.google.com with ESMTP id p2SMfd14030289
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 28 Mar 2011 15:41:57 -0700
Received: by pwi15 with SMTP id 15so597635pwi.19
        for <linux-mm@kvack.org>; Mon, 28 Mar 2011 15:41:56 -0700 (PDT)
Date: Mon, 28 Mar 2011 15:41:53 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 1/3] mm: Optimize pfn calculation in online_page()
In-Reply-To: <20110328092310.GB13826@router-fw-old.local.net-space.pl>
Message-ID: <alpine.DEB.2.00.1103281541420.7148@chino.kir.corp.google.com>
References: <20110328092310.GB13826@router-fw-old.local.net-space.pl>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, v.tolstov@selfip.ru, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 28 Mar 2011, Daniel Kiper wrote:

> If CONFIG_FLATMEM is enabled pfn is calculated in online_page()
> more than once. It is possible to optimize that and use value
> established at beginning of that function.
> 
> Signed-off-by: Daniel Kiper <dkiper@net-space.pl>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
