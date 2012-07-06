Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 2B3CA6B0074
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 05:07:03 -0400 (EDT)
Message-ID: <4FF6AA11.2010303@parallels.com>
Date: Fri, 6 Jul 2012 13:04:17 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH SLAB 1/2 v3] duplicate the cache name in SLUB's saved_alias
 list, SLAB, and SLOB
References: <1341561286.24895.9.camel@ThinkPad-T420>
In-Reply-To: <1341561286.24895.9.camel@ThinkPad-T420>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zhong <zhong@linux.vnet.ibm.com>
Cc: LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linux-mm <linux-mm@kvack.org>, PowerPC email list <linuxppc-dev@lists.ozlabs.org>, Wanlong Gao <gaowanlong@cn.fujitsu.com>

On 07/06/2012 11:54 AM, Li Zhong wrote:
> +	if (!c && lname)
> +		kfree(lname);
> +
kfree can still be validly called with a NULL argument. No need for the
lname in the conditional.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
