Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id B53266B007E
	for <linux-mm@kvack.org>; Wed,  7 Mar 2012 17:21:45 -0500 (EST)
Received: by ggeq1 with SMTP id q1so3413886gge.14
        for <linux-mm@kvack.org>; Wed, 07 Mar 2012 14:21:44 -0800 (PST)
Date: Wed, 7 Mar 2012 14:21:42 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: PATCH 1/2] rmap: cleanup anon_vma_prepare
In-Reply-To: <4F575100.30502@linux.vnet.ibm.com>
Message-ID: <alpine.DEB.2.00.1203071421320.22091@chino.kir.corp.google.com>
References: <4F575045.9010904@linux.vnet.ibm.com> <4F575100.30502@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed, 7 Mar 2012, Xiao Guangrong wrote:

> Sorry for the title typo, repost it.
> 
> -------------------->
> Subject: [PATCH 1/2] rmap: cleanup anon_vma_prepare
> 
> Using the common function anon_vma_chain_link() to link vma and anon_vma
> 
> Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
