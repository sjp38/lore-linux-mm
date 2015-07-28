Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f169.google.com (mail-yk0-f169.google.com [209.85.160.169])
	by kanga.kvack.org (Postfix) with ESMTP id 073F96B0254
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 10:54:38 -0400 (EDT)
Received: by ykdu72 with SMTP id u72so97439255ykd.2
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 07:54:37 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id p193si15556400ykd.77.2015.07.28.07.54.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Jul 2015 07:54:37 -0700 (PDT)
Date: Tue, 28 Jul 2015 16:54:26 +0200
From: Daniel Kiper <daniel.kiper@oracle.com>
Subject: Re: [PATCHv2 01/10] mm: memory hotplug with an existing resource
Message-ID: <20150728145426.GI3492@olila.local.net-space.pl>
References: <1437738468-24110-1-git-send-email-david.vrabel@citrix.com>
 <1437738468-24110-2-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437738468-24110-2-git-send-email-david.vrabel@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: xen-devel@lists.xenproject.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On Fri, Jul 24, 2015 at 12:47:39PM +0100, David Vrabel wrote:
> Add add_memory_resource() to add memory using an existing "System RAM"
> resource.  This is useful if the memory region is being located by
> finding a free resource slot with allocate_resource().
>
> Xen guests will make use of this in their balloon driver to hotplug
> arbitrary amounts of memory in response to toolstack requests.
>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>

Reviewed-by: Daniel Kiper <daniel.kiper@oracle.com>

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
