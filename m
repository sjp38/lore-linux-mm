Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id D2B1D6B0038
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 19:23:59 -0400 (EDT)
Received: by obre1 with SMTP id e1so64611680obr.1
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 16:23:59 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id 67si5528987oid.129.2015.07.31.16.23.59
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 16:23:59 -0700 (PDT)
Date: Sat, 1 Aug 2015 01:23:50 +0200
From: Daniel Kiper <daniel.kiper@oracle.com>
Subject: Re: [PATCHv3 10/10] xen/balloon: pre-allocate p2m entries for
 ballooned pages
Message-ID: <20150731232350.GE3488@olila.local.net-space.pl>
References: <1438275792-5726-1-git-send-email-david.vrabel@citrix.com>
 <1438275792-5726-11-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438275792-5726-11-git-send-email-david.vrabel@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On Thu, Jul 30, 2015 at 06:03:12PM +0100, David Vrabel wrote:
> Pages returned by alloc_xenballooned_pages() will be used for grant
> mapping which will call set_phys_to_machine() (in PV guests).
>
> Ballooned pages are set as INVALID_P2M_ENTRY in the p2m and thus may
> be using the (shared) missing tables and a subsequent
> set_phys_to_machine() will need to allocate new tables.
>
> Since the grant mapping may be done from a context that cannot sleep,
> the p2m entries must already be allocated.
>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Reviewed-by: Daniel Kiper <daniel.kiper@oracle.com>

Daniel

PS FYI, next week I am on vacation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
