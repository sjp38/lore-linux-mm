Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A72D26B0007
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 14:41:21 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id k5-v6so3663890edq.9
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 11:41:21 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o92-v6si6228300edd.195.2018.07.05.11.41.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 05 Jul 2018 11:41:20 -0700 (PDT)
Date: Thu, 5 Jul 2018 14:43:52 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [BUG] Swap xarray workingset eviction warning.
Message-ID: <20180705184352.GA16681@cmpxchg.org>
References: <2920a634-0646-1500-7c4d-62c56932fe49@gmail.com>
 <20180702025059.GA9865@bombadil.infradead.org>
 <20180705170019.GA14929@cmpxchg.org>
 <20180705175352.GA21635@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180705175352.GA21635@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Peter Geis <pgwipeout@gmail.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Thu, Jul 05, 2018 at 10:53:52AM -0700, Matthew Wilcox wrote:
> On Thu, Jul 05, 2018 at 01:00:19PM -0400, Johannes Weiner wrote:
> > This could be a matter of uptime, but the warning triggers on a thing
> > that is supposed to happen everywhere eventually. Let's fix it.
> 
> Ahh!  Thank you!
> 
> > xa_mk_value() doesn't understand that we're okay with it chopping off
> > our upper-most bit. We shouldn't make this an API behavior, either, so
> > let's fix the workingset code to always clear those bits before hand.
> 
> Makes sense.  I'll just fold this in, if that's OK with you?

Sounds good to me, thanks.
