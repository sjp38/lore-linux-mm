Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1441A6B004F
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 23:19:52 -0400 (EDT)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: Page allocation failures in guest
Date: Wed, 12 Aug 2009 12:49:51 +0930
References: <20090713115158.0a4892b0@mjolnir.ossman.eu> <20090811083233.3b2be444@mjolnir.ossman.eu> <4A811545.5090209@redhat.com>
In-Reply-To: <4A811545.5090209@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200908121249.51973.rusty@rustcorp.com.au>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Pierre Ossman <drzeus-list@drzeus.cx>, Minchan Kim <minchan.kim@gmail.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, 11 Aug 2009 04:22:53 pm Avi Kivity wrote:
> On 08/11/2009 09:32 AM, Pierre Ossman wrote:
> > On Mon, 13 Jul 2009 23:59:52 +0900
> > Minchan Kim<minchan.kim@gmail.com>  wrote:
> > Any ideas here? Is the virtio net driver very GFP_ATOMIC happy so it
> > drains all those pages? And why is this triggered by a kernel upgrade
> > in the host?
> >
> > Avi? 
> 
> Rusty?

It's kind of the nature of networking devices :(

I'd say your host now offers GSO features, so the guest allocates big
packets.

> > I doesn't get out of it though, or at least the virtio net driver
> > wedges itself.

There's a fixme to retry when this happens, but this is the first report
I've received.  I'll check it out.

Thanks,
Rusty.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
