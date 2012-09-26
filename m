Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx190.postini.com [74.125.245.190])
	by kanga.kvack.org (Postfix) with SMTP id 0577A6B005D
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 00:13:59 -0400 (EDT)
Received: by pbbrq2 with SMTP id rq2so1356222pbb.14
        for <linux-mm@kvack.org>; Tue, 25 Sep 2012 21:13:59 -0700 (PDT)
Date: Tue, 25 Sep 2012 21:13:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/slab: Fix typo _RET_IP -> _RET_IP_
In-Reply-To: <1348571229-844-1-git-send-email-elezegarcia@gmail.com>
Message-ID: <alpine.DEB.2.00.1209252113010.28360@chino.kir.corp.google.com>
References: <1348571229-844-1-git-send-email-elezegarcia@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ezequiel Garcia <elezegarcia@gmail.com>
Cc: kernel-janitors@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com, Pekka Enberg <penberg@kernel.org>

On Tue, 25 Sep 2012, Ezequiel Garcia wrote:

> The bug was introduced by commit 7c0cb9c64f83
> "mm, slab: Replace 'caller' type, void* -> unsigned long".
> 

That commit SHA1 may not remain consistent, so it's better to just mention 
the name of the patch.  I also didn't see this in linux-next and had to 
look at Pekka's slab/next tree to find it since it wasn't indicated in the 
patch.

> Cc: Pekka Enberg <penberg@kernel.org>
> Reported-by: Fengguang Wu <fengguang.wu@intel.com>
> Signed-off-by: Ezequiel Garcia <elezegarcia@gmail.com>

Acked-by: David Rientjes <rientjes@google.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
