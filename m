Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id C650D6B005C
	for <linux-mm@kvack.org>; Tue,  3 Jul 2012 14:48:04 -0400 (EDT)
Date: Tue, 3 Jul 2012 13:48:01 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH powerpc 2/2] kfree the cache name  of pgtable cache if
 SLUB is used
In-Reply-To: <1340618099.13778.39.camel@ThinkPad-T420>
Message-ID: <alpine.DEB.2.00.1207031344240.14703@router.home>
References: <1340617984.13778.37.camel@ThinkPad-T420> <1340618099.13778.39.camel@ThinkPad-T420>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zhong <zhong@linux.vnet.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm <linux-mm@kvack.org>, PowerPC email list <linuxppc-dev@lists.ozlabs.org>

On Mon, 25 Jun 2012, Li Zhong wrote:

> This patch tries to kfree the cache name of pgtables cache if SLUB is
> used, as SLUB duplicates the cache name, and the original one is leaked.

SLAB also does not free the name. Why would you have an #ifdef in there?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
