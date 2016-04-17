Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 4D7B96B007E
	for <linux-mm@kvack.org>; Sun, 17 Apr 2016 13:24:45 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id o131so326973094ywc.2
        for <linux-mm@kvack.org>; Sun, 17 Apr 2016 10:24:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g6si20390128qkb.57.2016.04.17.10.24.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 17 Apr 2016 10:24:44 -0700 (PDT)
Date: Sun, 17 Apr 2016 19:24:32 +0200
From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: FlameGraph of mlx4 early drop with order-0 pages
Message-ID: <20160417192432.70c893fc@redhat.com>
In-Reply-To: <20160417132357.GB11792@techsingularity.net>
References: <20160415214034.6ffae9ee@redhat.com>
	<20160417132357.GB11792@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm <linux-mm@kvack.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Brenden Blanco <bblanco@plumgrid.com>, tom@herbertland.com, alexei.starovoitov@gmail.com, ogerlitz@mellanox.com, daniel@iogearbox.net, eric.dumazet@gmail.com, ecree@solarflare.com, john.fastabend@gmail.com, tgraf@suug.ch, johannes@sipsolutions.net, brouer@redhat.com

On Sun, 17 Apr 2016 14:23:57 +0100
Mel Gorman <mgorman@techsingularity.net> wrote:

> > Signing off, heading for the plane soon... see you at MM-summit!  
> 
> Indeed and we'll slap some sort of plan together. If there is a slot free,
> we might spend 15-30 minutes on it. Failing that, we'll grab a table
> somewhere. We'll see how far we can get before considering a page-recycle
> layer that preserves cache coherent state.

We have a plenum slot tomorrow between 16:00-16:30, called "Generic
Page Pool Facility".

I'm at the Marriott now. I'm wearing my Red Hat/fedora, so I should be
easy to spot... ;-)

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
