Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 682EC6B0006
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 08:02:56 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id t78-v6so2228810pfa.8
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 05:02:56 -0700 (PDT)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id j38-v6si3320815pgj.613.2018.07.18.05.02.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Jul 2018 05:02:55 -0700 (PDT)
Date: Wed, 18 Jul 2018 06:02:49 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH v2 00/11] docs/mm: add boot time memory management docs
Message-ID: <20180718060249.6b45605d@lwn.net>
In-Reply-To: <20180718114730.GD4302@rapoport-lnx>
References: <1530370506-21751-1-git-send-email-rppt@linux.vnet.ibm.com>
	<20180702113255.1f7504e2@lwn.net>
	<20180718114730.GD4302@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Randy Dunlap <rdunlap@infradead.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Wed, 18 Jul 2018 14:47:30 +0300
Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:

> > So this seems like good stuff overall.  It digs pretty deeply into the mm
> > code, though, so I'm a little reluctant to apply it without an ack from an
> > mm developer.  Alternatively, I'm happy to step back if Andrew wants to
> > pick the set up.  
> 
> Jon, does Michal's reply [1] address your concerns?
> Or should I respin and ask Andrew to pick it up? 
> 
> [1] https://lore.kernel.org/lkml/20180712080006.GA328@dhcp22.suse.cz/

Michal acked #11 (the docs patch) in particular but not the series as a
whole.  But it's the rest of the series that I was most worried about :)
I'm happy for the patches to take either path, but I'd really like an
explicit ack before I apply that many changes directly to the MM code...

Thanks,

jon
