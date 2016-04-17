Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4D8E86B007E
	for <linux-mm@kvack.org>; Sun, 17 Apr 2016 13:52:59 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id d19so99793027lfb.0
        for <linux-mm@kvack.org>; Sun, 17 Apr 2016 10:52:59 -0700 (PDT)
Received: from outbound-smtp04.blacknight.com (outbound-smtp04.blacknight.com. [81.17.249.35])
        by mx.google.com with ESMTPS id 143si22731443wma.114.2016.04.17.10.52.57
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 17 Apr 2016 10:52:57 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp04.blacknight.com (Postfix) with ESMTPS id 56C8998DAD
	for <linux-mm@kvack.org>; Sun, 17 Apr 2016 17:52:57 +0000 (UTC)
Date: Sun, 17 Apr 2016 18:52:43 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: FlameGraph of mlx4 early drop with order-0 pages
Message-ID: <20160417175243.GA15167@techsingularity.net>
References: <20160415214034.6ffae9ee@redhat.com>
 <20160417132357.GB11792@techsingularity.net>
 <20160417192432.70c893fc@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160417192432.70c893fc@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Cc: linux-mm <linux-mm@kvack.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Brenden Blanco <bblanco@plumgrid.com>, tom@herbertland.com, alexei.starovoitov@gmail.com, ogerlitz@mellanox.com, daniel@iogearbox.net, eric.dumazet@gmail.com, ecree@solarflare.com, john.fastabend@gmail.com, tgraf@suug.ch, johannes@sipsolutions.net

On Sun, Apr 17, 2016 at 07:24:32PM +0200, Jesper Dangaard Brouer wrote:
> On Sun, 17 Apr 2016 14:23:57 +0100
> Mel Gorman <mgorman@techsingularity.net> wrote:
> 
> > > Signing off, heading for the plane soon... see you at MM-summit!  
> > 
> > Indeed and we'll slap some sort of plan together. If there is a slot free,
> > we might spend 15-30 minutes on it. Failing that, we'll grab a table
> > somewhere. We'll see how far we can get before considering a page-recycle
> > layer that preserves cache coherent state.
> 
> We have a plenum slot tomorrow between 16:00-16:30, called "Generic
> Page Pool Facility".
> 

Yeah. We can use part of that if you like to discuss page allocator
concerns. I didn't want to accidentally hijack a session if it was going
to focus on an API for storing cache coherent pages. My focus will still
be on improving the allocator itself and what would and would not be
acceptable there.

> I'm at the Marriott now. I'm wearing my Red Hat/fedora, so I should be
> easy to spot... ;-)
> 

I'll keep an eye out!

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
