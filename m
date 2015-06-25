Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 960BA6B006C
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 14:02:06 -0400 (EDT)
Received: by pdcu2 with SMTP id u2so58049096pdc.3
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 11:02:06 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id tu8si46261745pab.6.2015.06.25.11.02.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jun 2015 11:02:05 -0700 (PDT)
Date: Thu, 25 Jun 2015 20:01:53 +0200
From: Daniel Kiper <daniel.kiper@oracle.com>
Subject: Re: [PATCHv1 2/8] xen/balloon: remove scratch page left overs
Message-ID: <20150625180153.GJ14050@olila.local.net-space.pl>
References: <1435252263-31952-1-git-send-email-david.vrabel@citrix.com>
 <1435252263-31952-3-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1435252263-31952-3-git-send-email-david.vrabel@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: xen-devel@lists.xenproject.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jun 25, 2015 at 06:10:57PM +0100, David Vrabel wrote:
> Commit 0bb599fd30108883b00c7d4a226eeb49111e6932 (xen: remove scratch
> frames for ballooned pages and m2p override) removed the use of the
> scratch page for ballooned out pages.
>
> Remove some left over function definitions.
>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Reviewed-by: Daniel Kiper <daniel.kiper@oracle.com>

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
