Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f175.google.com (mail-yk0-f175.google.com [209.85.160.175])
	by kanga.kvack.org (Postfix) with ESMTP id C38316B0254
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 09:45:41 -0400 (EDT)
Received: by yknn9 with SMTP id n9so119859801ykn.0
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 06:45:41 -0700 (PDT)
Received: from SMTP02.CITRIX.COM (smtp02.citrix.com. [66.165.176.63])
        by mx.google.com with ESMTPS id s5si8831803ywd.151.2015.10.23.06.45.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 23 Oct 2015 06:45:41 -0700 (PDT)
Message-ID: <562A3A00.60509@citrix.com>
Date: Fri, 23 Oct 2015 14:45:36 +0100
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [Xen-devel] [PATCH] mm: hotplug: Don't release twice the resource
 on error
References: <1445605053-23274-1-git-send-email-julien.grall@citrix.com>
In-Reply-To: <1445605053-23274-1-git-send-email-julien.grall@citrix.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julien Grall <julien.grall@citrix.com>, xen-devel@lists.xenproject.org, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, David Vrabel <david.vrabel@citrix.com>

On 23/10/15 13:57, Julien Grall wrote:
> The function add_memory_resource take in parameter a resource allocated
> by the caller. On error, both add_memory_resource and the caller will
> release the resource via release_memory_source.
[...]
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -1298,7 +1298,6 @@ error:
>  	/* rollback pgdat allocation and others */
>  	if (new_pgdat)
>  		rollback_node_hotadd(nid, pgdat);
> -	release_memory_resource(res);
>  	memblock_remove(start, size);

I've folded this in, thanks.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
