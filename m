Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id F25EA6B0038
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 19:22:19 -0400 (EDT)
Received: by padck2 with SMTP id ck2so47732940pad.0
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 16:22:19 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id x14si13615349pas.117.2015.07.31.16.22.18
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 16:22:19 -0700 (PDT)
Date: Sat, 1 Aug 2015 01:22:08 +0200
From: Daniel Kiper <daniel.kiper@oracle.com>
Subject: Re: [PATCHv3 09/10] x86/xen: export xen_alloc_p2m_entry()
Message-ID: <20150731232208.GD3488@olila.local.net-space.pl>
References: <1438275792-5726-1-git-send-email-david.vrabel@citrix.com>
 <1438275792-5726-10-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438275792-5726-10-git-send-email-david.vrabel@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On Thu, Jul 30, 2015 at 06:03:11PM +0100, David Vrabel wrote:
> Rename alloc_p2m() to xen_alloc_p2m_entry() and export it.
>
> This is useful for ensuring that a p2m entry is allocated (i.e., not a
> shared missing or identity entry) so that subsequent set_phys_to_machine()
> calls will require no further allocations.
>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Reviewed-by: Daniel Kiper <daniel.kiper@oracle.com>

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
