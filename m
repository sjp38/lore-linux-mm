Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id 7D2C26B0038
	for <linux-mm@kvack.org>; Thu, 25 Jun 2015 14:54:55 -0400 (EDT)
Received: by obpn3 with SMTP id n3so53032123obp.0
        for <linux-mm@kvack.org>; Thu, 25 Jun 2015 11:54:55 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id k10si10911943obh.85.2015.06.25.11.54.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Jun 2015 11:54:54 -0700 (PDT)
Date: Thu, 25 Jun 2015 20:54:45 +0200
From: Daniel Kiper <daniel.kiper@oracle.com>
Subject: Re: [PATCHv1 5/8] xen/balloon: rationalize memory hotplug stats
Message-ID: <20150625185445.GN14050@olila.local.net-space.pl>
References: <1435252263-31952-1-git-send-email-david.vrabel@citrix.com>
 <1435252263-31952-6-git-send-email-david.vrabel@citrix.com>
 <20150625183836.GM14050@olila.local.net-space.pl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150625183836.GM14050@olila.local.net-space.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Vrabel <david.vrabel@citrix.com>
Cc: xen-devel@lists.xenproject.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jun 25, 2015 at 08:38:36PM +0200, Daniel Kiper wrote:
> On Thu, Jun 25, 2015 at 06:11:00PM +0100, David Vrabel wrote:
> > The stats used for memory hotplug make no sense and are fiddled with
> > in odd ways.  Remove them and introduce total_pages to track the total
> > number of pages (both populated and unpopulated) including those within
> > hotplugged regions (note that this includes not yet onlined pages).
> >
> > This will be useful when deciding whether additional memory needs to be
> > hotplugged.
> >
> > Signed-off-by: David Vrabel <david.vrabel@citrix.com>
>
> Nice optimization! I suppose that it is remnant from very early
> version of memory hotplug. Probably after a few patch series
> iterations hotplug_pages and balloon_hotplug lost their meaning
> and I did not catch it. Additionally, as I can see there is not
> any consumer for total_pages here. So, I think that we can go
> further and remove this obfuscated code at all.

Err... Ignore that. I missed next patch... Should not both of them
merged in one or commit comment contain clear info that this will
be used by next patch.

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
