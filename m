Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id DE2E86B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 14:03:50 -0400 (EDT)
Received: by pactm7 with SMTP id tm7so53785723pac.2
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 11:03:50 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id v8si46244803pds.131.2015.06.25.11.03.48
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jun 2015 11:03:50 -0700 (PDT)
Date: Thu, 25 Jun 2015 20:03:35 +0200
From: Daniel Kiper <daniel.kiper@oracle.com>
Subject: Re: [PATCHv1 3/8] x86/xen: discard RAM regions above the maximum
 reservation
Message-ID: <20150625180335.GK14050@olila.local.net-space.pl>
References: <1435252263-31952-1-git-send-email-david.vrabel@citrix.com>
 <1435252263-31952-4-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1435252263-31952-4-git-send-email-david.vrabel@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: xen-devel@lists.xenproject.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jun 25, 2015 at 06:10:58PM +0100, David Vrabel wrote:
> During setup, discard RAM regions that are above the maximum
> reservation (instead of marking them as E820_UNUSABLE).  This allows
> hotplug memory to be placed at these addresses.
>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Reviewed-by: Daniel Kiper <daniel.kiper@oracle.com>

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
