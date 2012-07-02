Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 65CF46B0062
	for <linux-mm@kvack.org>; Mon,  2 Jul 2012 06:56:03 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so9068882pbb.14
        for <linux-mm@kvack.org>; Mon, 02 Jul 2012 03:56:02 -0700 (PDT)
Date: Mon, 2 Jul 2012 03:55:59 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] slab: Fix a tpyo in commit 8c138b "slab: Get rid of
 obj_size macro"
In-Reply-To: <1341210550-11038-1-git-send-email-feng.tang@intel.com>
Message-ID: <alpine.DEB.2.00.1207020355180.14758@chino.kir.corp.google.com>
References: <1341210550-11038-1-git-send-email-feng.tang@intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Feng Tang <feng.tang@intel.com>
Cc: penberg@kernel.org, linux-kernel@vger.kernel.org, fengguang.wu@intel.com, sfr@canb.auug.org.au, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

On Mon, 2 Jul 2012, Feng Tang wrote:

> Commit  8c138b only sits in Pekka's and linux-next tree now, which tries
> to replace obj_size(cachep) with cachep->object_size, but has a typo in
> kmem_cache_free() by using "size" instead of "object_size", which casues
> some regressions.
> 

If you have a specific regression that you'd like to describe, that would 
be helpful here.  "Some regressions" isn't descriptive.

> Reported-and-tested-by: Fengguang Wu <wfg@linux.intel.com>
> Signed-off-by: Feng Tang <feng.tang@intel.com>
> Cc: Christoph Lameter <cl@linux.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
