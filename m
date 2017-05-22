Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id C5A516B02B4
	for <linux-mm@kvack.org>; Mon, 22 May 2017 17:14:17 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id j22so47248125qtj.15
        for <linux-mm@kvack.org>; Mon, 22 May 2017 14:14:17 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 26si19929139qkt.215.2017.05.22.14.14.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 22 May 2017 14:14:17 -0700 (PDT)
Date: Mon, 22 May 2017 18:13:41 -0300
From: Marcelo Tosatti <mtosatti@redhat.com>
Subject: Re: [patch 2/2] MM: allow per-cpu vmstat_threshold and vmstat_worker
 configuration
Message-ID: <20170522211337.GA4718@amt.cnet>
References: <20170512154026.GA3556@amt.cnet>
 <alpine.DEB.2.20.1705121103120.22831@east.gentwo.org>
 <20170512161915.GA4185@amt.cnet>
 <alpine.DEB.2.20.1705121154240.23503@east.gentwo.org>
 <20170515191531.GA31483@amt.cnet>
 <alpine.DEB.2.20.1705160825480.32761@east.gentwo.org>
 <20170519143407.GA19282@amt.cnet>
 <alpine.DEB.2.20.1705191205580.19631@east.gentwo.org>
 <20170520082646.GA16139@amt.cnet>
 <alpine.DEB.2.20.1705221137001.12282@east.gentwo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1705221137001.12282@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Luiz Capitulino <lcapitulino@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Linux RT Users <linux-rt-users@vger.kernel.org>, cmetcalf@mellanox.com

On Mon, May 22, 2017 at 11:38:02AM -0500, Christoph Lameter wrote:
> On Sat, 20 May 2017, Marcelo Tosatti wrote:
> 
> > > And you can configure the interval of vmstat updates freely.... Set
> > > the vmstat_interval to 60 seconds instead of 2 for a try? Is that rare
> > > enough?
> >
> > Not rare enough. Never is rare enough.
> 
> Ok what about the other stuff that must be going on if you allow OS
> activity like f.e. the tick, scheduler etc etc.

Yes these are also problems... but we're either getting rid of them or
reducing their impact as much as possible.

vmstat_update is one member of the problematic set.

I'll get you the detailed IPI measures, hold on...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
