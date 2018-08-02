Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7C4096B0003
	for <linux-mm@kvack.org>; Thu,  2 Aug 2018 14:36:51 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id v9-v6so1985506pfn.6
        for <linux-mm@kvack.org>; Thu, 02 Aug 2018 11:36:51 -0700 (PDT)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id 6-v6si2781624pgz.592.2018.08.02.11.36.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Aug 2018 11:36:49 -0700 (PDT)
Date: Thu, 2 Aug 2018 12:36:46 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH v2 00/11] docs/mm: add boot time memory management docs
Message-ID: <20180802123646.4cc299b5@lwn.net>
In-Reply-To: <20180726154557.7a1677d8@lwn.net>
References: <1530370506-21751-1-git-send-email-rppt@linux.vnet.ibm.com>
	<20180702113255.1f7504e2@lwn.net>
	<20180718114730.GD4302@rapoport-lnx>
	<20180718060249.6b45605d@lwn.net>
	<20180718170043.GA23770@rapoport-lnx>
	<20180726154557.7a1677d8@lwn.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Randy Dunlap <rdunlap@infradead.org>, linux-doc <linux-doc@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Thu, 26 Jul 2018 15:45:57 -0600
Jonathan Corbet <corbet@lwn.net> wrote:

> It seems this hasn't happened - at least, I don't see the patches in
> linux-next.  Unless somebody says something I think I'll just go ahead and
> merge the set.  It all still applies cleanly enough, no conflicts against
> -next, and I'd hate to see this work fall through the cracks.

So I have now merged this set, thanks.

jon
