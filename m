Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f51.google.com (mail-yh0-f51.google.com [209.85.213.51])
	by kanga.kvack.org (Postfix) with ESMTP id C9B3C6B0038
	for <linux-mm@kvack.org>; Fri, 26 Jun 2015 04:59:30 -0400 (EDT)
Received: by yhnv31 with SMTP id v31so40466405yhn.1
        for <linux-mm@kvack.org>; Fri, 26 Jun 2015 01:59:30 -0700 (PDT)
Received: from SMTP.CITRIX.COM (smtp.citrix.com. [66.165.176.89])
        by mx.google.com with ESMTPS id r184si12642024yke.167.2015.06.26.01.59.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 26 Jun 2015 01:59:30 -0700 (PDT)
Message-ID: <558D1458.1000300@citrix.com>
Date: Fri, 26 Jun 2015 09:59:04 +0100
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [Xen-devel] [PATCHv1 5/8] xen/balloon: rationalize memory hotplug
 stats
References: <1435252263-31952-1-git-send-email-david.vrabel@citrix.com>
	<1435252263-31952-6-git-send-email-david.vrabel@citrix.com>
	<20150625183836.GM14050@olila.local.net-space.pl>
	<20150625185445.GN14050@olila.local.net-space.pl>
 <20150625213113.GP14050@olila.local.net-space.pl>
In-Reply-To: <20150625213113.GP14050@olila.local.net-space.pl>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <daniel.kiper@oracle.com>, David Vrabel <david.vrabel@citrix.com>
Cc: linux-mm@kvack.org, xen-devel@lists.xenproject.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, linux-kernel@vger.kernel.org

On 25/06/15 22:31, Daniel Kiper wrote:
> On Thu, Jun 25, 2015 at 08:54:45PM +0200, Daniel Kiper wrote:
>
> It looks that balloon_stats.total_pages is used only in memory hotplug case.
> Please do references (and definition) to it inside #ifdef CONFIG_XEN_BALLOON_MEMORY_HOTPLUG
> like it is done in balloon_stats.hotplug_pages and balloon_stats.balloon_hotplug case.

I don't think the space saving here really warrants sprinkling a bunch
of #ifdefs around.

David

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
