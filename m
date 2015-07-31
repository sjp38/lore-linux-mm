Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f169.google.com (mail-ob0-f169.google.com [209.85.214.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0669F6B0038
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 19:20:57 -0400 (EDT)
Received: by obre1 with SMTP id e1so64577527obr.1
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 16:20:56 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id x79si5539068oix.80.2015.07.31.16.20.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 16:20:53 -0700 (PDT)
Date: Sat, 1 Aug 2015 01:20:31 +0200
From: Daniel Kiper <daniel.kiper@oracle.com>
Subject: Re: [PATCHv3 08/10] xen/balloon: use hotplugged pages for foreign
 mappings etc.
Message-ID: <20150731232031.GC3488@olila.local.net-space.pl>
References: <1438275792-5726-1-git-send-email-david.vrabel@citrix.com>
 <1438275792-5726-9-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438275792-5726-9-git-send-email-david.vrabel@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On Thu, Jul 30, 2015 at 06:03:10PM +0100, David Vrabel wrote:
> alloc_xenballooned_pages() is used to get ballooned pages to back
> foreign mappings etc.  Instead of having to balloon out real pages,
> use (if supported) hotplugged memory.
>
> This makes more memory available to the guest and reduces
> fragmentation in the p2m.
>
> This is only enabled if the xen.balloon.hotplug_unpopulated sysctl is
> set to 1.  This sysctl defaults to 0 in case the udev rules to
> automatically online hotplugged memory do not exist.
>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Reviewed-by: Daniel Kiper <daniel.kiper@oracle.com>

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
