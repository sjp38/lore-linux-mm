Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f177.google.com (mail-ob0-f177.google.com [209.85.214.177])
	by kanga.kvack.org (Postfix) with ESMTP id 5E9466B0253
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 15:37:50 -0400 (EDT)
Received: by obdeg2 with SMTP id eg2so67666454obd.0
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 12:37:50 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id xj4si14343757oeb.73.2015.07.27.12.37.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jul 2015 12:37:49 -0700 (PDT)
Date: Mon, 27 Jul 2015 21:37:34 +0200
From: Daniel Kiper <daniel.kiper@oracle.com>
Subject: Re: [PATCHv2 00/10] mm, xen/balloon: memory hotplug improvements
Message-ID: <20150727193734.GA3492@olila.local.net-space.pl>
References: <1437738468-24110-1-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437738468-24110-1-git-send-email-david.vrabel@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: xen-devel@lists.xenproject.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jul 24, 2015 at 12:47:38PM +0100, David Vrabel wrote:
> The series improves the use of hotplug memory in the Xen balloon
> driver.
>
> - Reliably find a non-conflicting location for the hotplugged memory
>   (this fixes memory hotplug in a number of cases, particularly in
>   dom0).
>
> - Use hotplugged memory for alloc_xenballooned_pages() (keeping more
>   memory available for the domain and reducing fragmentation of the
>   p2m).
>
> Changes in v2:
> - New BP_WAIT state to signal the balloon process to wait for
>   userspace to online the new memory.
> - Preallocate P2M entries in alloc_xenballooned_pages() so they do not
>   need allocated later (in a context where GFP_KERNEL allocations are
>   not possible).

Thanks! I will take a look at it this week.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
