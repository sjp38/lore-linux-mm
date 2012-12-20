Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id 088F16B0068
	for <linux-mm@kvack.org>; Wed, 19 Dec 2012 21:25:38 -0500 (EST)
Message-ID: <50D27707.7060309@oracle.com>
Date: Wed, 19 Dec 2012 21:25:11 -0500
From: Sasha Levin <sasha.levin@oracle.com>
MIME-Version: 1.0
Subject: Re: [PATCH 04/15] mm/huge_memory: use new hashtable implementation
References: <1355756497-15834-1-git-send-email-sasha.levin@oracle.com> <1355756497-15834-4-git-send-email-sasha.levin@oracle.com> <alpine.DEB.2.00.1212191416410.32757@chino.kir.corp.google.com>
In-Reply-To: <alpine.DEB.2.00.1212191416410.32757@chino.kir.corp.google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 12/19/2012 05:26 PM, David Rientjes wrote:
> This used to be dynamically allocated and would save the 8KB that you 
> statically allocate if transparent hugepages cannot be used.  The generic 
> hashtable implementation does not support dynamic allocation?

No, currently the hashtable only handles statically allocated hashtables.

In this case, the downside is that you'll waste 8KB if hugepages aren't available,
but the upside is that you'll have one less dereference when accessing the
hashtable.

If the 8KB saving is preferable here I'll drop the patch and come back when
dynamic hashtable is supported.


Thanks,
Sasha

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
