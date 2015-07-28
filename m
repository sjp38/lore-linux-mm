Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f50.google.com (mail-oi0-f50.google.com [209.85.218.50])
	by kanga.kvack.org (Postfix) with ESMTP id D5E4A6B0038
	for <linux-mm@kvack.org>; Tue, 28 Jul 2015 11:22:57 -0400 (EDT)
Received: by oige126 with SMTP id e126so71137501oig.0
        for <linux-mm@kvack.org>; Tue, 28 Jul 2015 08:22:57 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id s14si16775528oie.90.2015.07.28.08.22.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Jul 2015 08:22:57 -0700 (PDT)
Date: Tue, 28 Jul 2015 17:22:48 +0200
From: Daniel Kiper <daniel.kiper@oracle.com>
Subject: Re: [PATCHv2 05/10] xen/balloon: rationalize memory hotplug stats
Message-ID: <20150728152248.GJ3492@olila.local.net-space.pl>
References: <1437738468-24110-1-git-send-email-david.vrabel@citrix.com>
 <1437738468-24110-6-git-send-email-david.vrabel@citrix.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437738468-24110-6-git-send-email-david.vrabel@citrix.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: xen-devel@lists.xenproject.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Jul 24, 2015 at 12:47:43PM +0100, David Vrabel wrote:
> The stats used for memory hotplug make no sense and are fiddled with
> in odd ways.  Remove them and introduce total_pages to track the total
> number of pages (both populated and unpopulated) including those within
> hotplugged regions (note that this includes not yet onlined pages).
>
> This will be used in the following commit when deciding whether
> additional memory needs to be hotplugged.
>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Reviewed-by: Daniel Kiper <daniel.kiper@oracle.com>

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
