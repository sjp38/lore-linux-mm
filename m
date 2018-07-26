Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 18ACC6B0007
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 17:46:00 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id d12-v6so1671322pgv.12
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 14:46:00 -0700 (PDT)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id o66-v6si2439601pfb.125.2018.07.26.14.45.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 14:45:58 -0700 (PDT)
Date: Thu, 26 Jul 2018 15:45:57 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH v2 00/11] docs/mm: add boot time memory management docs
Message-ID: <20180726154557.7a1677d8@lwn.net>
In-Reply-To: <20180718170043.GA23770@rapoport-lnx>
References: <1530370506-21751-1-git-send-email-rppt@linux.vnet.ibm.com>
	<20180702113255.1f7504e2@lwn.net>
	<20180718114730.GD4302@rapoport-lnx>
	<20180718060249.6b45605d@lwn.net>
	<20180718170043.GA23770@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Randy Dunlap <rdunlap@infradead.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Wed, 18 Jul 2018 20:00:43 +0300
Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:

> > Michal acked #11 (the docs patch) in particular but not the series as a
> > whole.  But it's the rest of the series that I was most worried about :)
> > I'm happy for the patches to take either path, but I'd really like an
> > explicit ack before I apply that many changes directly to the MM code...  
> 
> Andrew,
> 
> Can you please take a look at this series? The thread starts at [1] and if
> it'd be more convenient to you I can respin the whole set.

It seems this hasn't happened - at least, I don't see the patches in
linux-next.  Unless somebody says something I think I'll just go ahead and
merge the set.  It all still applies cleanly enough, no conflicts against
-next, and I'd hate to see this work fall through the cracks.

jon
