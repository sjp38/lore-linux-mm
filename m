Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 503759003C7
	for <linux-mm@kvack.org>; Wed, 29 Jul 2015 12:11:17 -0400 (EDT)
Received: by pabkd10 with SMTP id kd10so7944390pab.2
        for <linux-mm@kvack.org>; Wed, 29 Jul 2015 09:11:17 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id ci16si62577028pdb.76.2015.07.29.09.11.15
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jul 2015 09:11:16 -0700 (PDT)
Date: Wed, 29 Jul 2015 18:10:56 +0200
From: Daniel Kiper <daniel.kiper@oracle.com>
Subject: Re: [PATCHv2 09/10] x86/xen: export xen_alloc_p2m_entry()
Message-ID: <20150729161056.GM3492@olila.local.net-space.pl>
References: <1437738468-24110-1-git-send-email-david.vrabel@citrix.com>
 <1437738468-24110-10-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437738468-24110-10-git-send-email-david.vrabel@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: xen-devel@lists.xenproject.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jul 24, 2015 at 12:47:47PM +0100, David Vrabel wrote:
> Rename alloc_p2m() to xen_alloc_p2m_entry() and export it.
>
> This is useful for ensuring that a p2m entry is allocated (i.e., not a
> shared missing or identity entry) so that subsequent set_phys_to_machine()
> calls will require no further allocations.
>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Reviewed-by: Daniel Kiper <daniel.kiper@oracle.com>

... but please add line in commit message saying that stuff from
this patch will be used by next one.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
