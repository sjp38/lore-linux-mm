Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 0D7C16B005D
	for <linux-mm@kvack.org>; Sat, 13 Oct 2012 05:56:02 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rq2so3994582pbb.14
        for <linux-mm@kvack.org>; Sat, 13 Oct 2012 02:56:02 -0700 (PDT)
Date: Sat, 13 Oct 2012 02:56:00 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: cleanup register_node()
In-Reply-To: <5077D353.3010708@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1210130255470.7462@chino.kir.corp.google.com>
References: <5077D353.3010708@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org

On Fri, 12 Oct 2012, Yasuaki Ishimatsu wrote:

> register_node() is defined as extern in include/linux/node.h. But the function
> is only called from register_one_node() in driver/base/node.c.
> 
> So the patch defines register_node() as static.
> 
> CC: David Rientjes <rientjes@google.com>
> CC: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Acked-by: David Rientjes <rientjes@google.com>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
