Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 899E56B0003
	for <linux-mm@kvack.org>; Thu, 26 Jul 2018 18:08:28 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id a26-v6so1715784pgw.7
        for <linux-mm@kvack.org>; Thu, 26 Jul 2018 15:08:28 -0700 (PDT)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id i62-v6si2466450pfc.217.2018.07.26.15.08.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Jul 2018 15:08:27 -0700 (PDT)
Date: Thu, 26 Jul 2018 16:08:25 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH v3 6/7] docs/mm: make GFP flags descriptions usable as
 kernel-doc
Message-ID: <20180726160825.0667af9f@lwn.net>
In-Reply-To: <1532626360-16650-7-git-send-email-rppt@linux.vnet.ibm.com>
References: <1532626360-16650-1-git-send-email-rppt@linux.vnet.ibm.com>
	<1532626360-16650-7-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 26 Jul 2018 20:32:39 +0300
Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:

> This patch adds DOC: headings for GFP flag descriptions and adjusts the
> formatting to fit sphinx expectations of paragraphs.

So I think this is a great thing to do.  Adding cross references from
places where GFP flags are expected would be even better.  I do have one
little concern, though...

> - * __GFP_MOVABLE (also a zone modifier) indicates that the page can be
> - *   moved by page migration during memory compaction or can be reclaimed.
> + * %__GFP_MOVABLE (also a zone modifier) indicates that the page can be
> + * moved by page migration during memory compaction or can be reclaimed.

There are Certain Developers who get rather bent out of shape when they
feel that excessive markup is degrading the readability of the plain-text
documentation.  I have a suspicion that all of these % signs might turn
out to be one of those places.  People have been trained to expect them in
function documentation, but that's not quite what we have here.

I won't insist on this, but I would suggest that, in this particular case,
it might be better for that markup to come out.

Then we have the same old question of who applies these.  I'd love to have
an ack from somebody who can speak for mm - or a statement that these will
go through another tree.  Preferably quickly so that this stuff can get
in through the upcoming merge window.

Thanks,

jon
