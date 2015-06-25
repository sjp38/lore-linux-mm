Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id A36B96B0073
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 17:37:11 -0400 (EDT)
Received: by pdcu2 with SMTP id u2so61114329pdc.3
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 14:37:11 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id n5si46986953pdk.140.2015.06.25.14.37.09
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jun 2015 14:37:10 -0700 (PDT)
Date: Thu, 25 Jun 2015 23:36:52 +0200
From: Daniel Kiper <daniel.kiper@oracle.com>
Subject: Re: [PATCHv1 7/8] xen/balloon: make alloc_xenballoon_pages() always
 allocate low pages
Message-ID: <20150625213652.GQ14050@olila.local.net-space.pl>
References: <1435252263-31952-1-git-send-email-david.vrabel@citrix.com>
 <1435252263-31952-8-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1435252263-31952-8-git-send-email-david.vrabel@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: xen-devel@lists.xenproject.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jun 25, 2015 at 06:11:02PM +0100, David Vrabel wrote:
> All users of alloc_xenballoon_pages() wanted low memory pages, so
> remove the option for high memory.
>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Reviewed-by: Daniel Kiper <daniel.kiper@oracle.com>

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
