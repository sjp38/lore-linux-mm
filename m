Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 393E66B0038
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 19:15:51 -0400 (EDT)
Received: by pdjr16 with SMTP id r16so50756027pdj.3
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 16:15:51 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id bk6si13526401pad.202.2015.07.31.16.15.49
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 16:15:50 -0700 (PDT)
Date: Sat, 1 Aug 2015 01:15:24 +0200
From: Daniel Kiper <daniel.kiper@oracle.com>
Subject: Re: [PATCHv3 01/10] mm: memory hotplug with an existing resource
Message-ID: <20150731231524.GA3488@olila.local.net-space.pl>
References: <1438275792-5726-1-git-send-email-david.vrabel@citrix.com>
 <1438275792-5726-2-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438275792-5726-2-git-send-email-david.vrabel@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Andrew Morton <akpm@linux-foundation.org>

On Thu, Jul 30, 2015 at 06:03:03PM +0100, David Vrabel wrote:
> Add add_memory_resource() to add memory using an existing "System RAM"
> resource.  This is useful if the memory region is being located by
> finding a free resource slot with allocate_resource().
>
> Xen guests will make use of this in their balloon driver to hotplug
> arbitrary amounts of memory in response to toolstack requests.
>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>

Hmmm... Why do you remove my Reviewed-by line from this patch?

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
