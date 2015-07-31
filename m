Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id E8F066B0038
	for <linux-mm@kvack.org>; Fri, 31 Jul 2015 19:18:38 -0400 (EDT)
Received: by pabkd10 with SMTP id kd10so47646119pab.2
        for <linux-mm@kvack.org>; Fri, 31 Jul 2015 16:18:38 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id pn2si13634180pdb.96.2015.07.31.16.18.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Jul 2015 16:18:37 -0700 (PDT)
Date: Sat, 1 Aug 2015 01:18:26 +0200
From: Daniel Kiper <daniel.kiper@oracle.com>
Subject: Re: [PATCHv3 06/10] xen/balloon: only hotplug additional memory if
 required
Message-ID: <20150731231826.GB3488@olila.local.net-space.pl>
References: <1438275792-5726-1-git-send-email-david.vrabel@citrix.com>
 <1438275792-5726-7-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1438275792-5726-7-git-send-email-david.vrabel@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: linux-kernel@vger.kernel.org, xen-devel@lists.xenproject.org, linux-mm@kvack.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>

On Thu, Jul 30, 2015 at 06:03:08PM +0100, David Vrabel wrote:
> Now that we track the total number of pages (included hotplugged
> regions), it is easy to determine if more memory needs to be
> hotplugged.
>
> Add a new BP_WAIT state to signal that the balloon process needs to
> wait until kicked by the memory add notifier (when the new section is
> onlined by userspace).
>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Reviewed-by: Daniel Kiper <daniel.kiper@oracle.com>

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
