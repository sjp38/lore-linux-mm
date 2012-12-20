Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 5C7D36B0072
	for <linux-mm@kvack.org>; Thu, 20 Dec 2012 15:28:16 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id bh2so2338909pad.33
        for <linux-mm@kvack.org>; Thu, 20 Dec 2012 12:28:15 -0800 (PST)
Date: Thu, 20 Dec 2012 12:28:13 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH 04/15] mm/huge_memory: use new hashtable implementation
In-Reply-To: <50D27707.7060309@oracle.com>
Message-ID: <alpine.DEB.2.00.1212201224190.29839@chino.kir.corp.google.com>
References: <1355756497-15834-1-git-send-email-sasha.levin@oracle.com> <1355756497-15834-4-git-send-email-sasha.levin@oracle.com> <alpine.DEB.2.00.1212191416410.32757@chino.kir.corp.google.com> <50D27707.7060309@oracle.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 19 Dec 2012, Sasha Levin wrote:

> In this case, the downside is that you'll waste 8KB if hugepages aren't available,
> but the upside is that you'll have one less dereference when accessing the
> hashtable.
> 
> If the 8KB saving is preferable here I'll drop the patch and come back when
> dynamic hashtable is supported.
> 

If a distro releases with CONFIG_TRANSPARNET_HUGEPAGE=y and a user is 
running on a processor that does not support pse then this just cost them 
8KB for no reason.  The overhead by simply enabling 
CONFIG_TRANSPARENT_HUGEPAGE is worse in this scenario, but this is whole 
reason for having the dynamic allocation in the original code.  If there's 
a compelling reason for why we want this change, then that fact should at 
least be documented.

Could you propose a v2 that includes fixes for the other problems that 
were mentioned?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
