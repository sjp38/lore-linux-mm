Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3204C6B0010
	for <linux-mm@kvack.org>; Fri, 27 Jul 2018 17:29:35 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id n19-v6so3628390pgv.14
        for <linux-mm@kvack.org>; Fri, 27 Jul 2018 14:29:35 -0700 (PDT)
Received: from ms.lwn.net (ms.lwn.net. [45.79.88.28])
        by mx.google.com with ESMTPS id i8-v6si4720368pgj.33.2018.07.27.14.29.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Jul 2018 14:29:34 -0700 (PDT)
Date: Fri, 27 Jul 2018 15:29:32 -0600
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [PATCH v3 6/7] docs/mm: make GFP flags descriptions usable as
 kernel-doc
Message-ID: <20180727152932.0ead76d1@lwn.net>
In-Reply-To: <20180727212720.GD17745@rapoport-lnx>
References: <1532626360-16650-1-git-send-email-rppt@linux.vnet.ibm.com>
	<1532626360-16650-7-git-send-email-rppt@linux.vnet.ibm.com>
	<20180726160825.0667af9f@lwn.net>
	<20180727212720.GD17745@rapoport-lnx>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Matthew Wilcox <willy@infradead.org>, Michal Hocko <mhocko@kernel.org>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 28 Jul 2018 00:27:21 +0300
Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:

> > I won't insist on this, but I would suggest that, in this particular case,
> > it might be better for that markup to come out.  
> 
> No problem with removing % signs, but the whitespace changes are necessary,
> otherwise the generated html gets weird.

The whitespace changes are fine - it's really just the % markup I was
commenting on.

Thanks,

jon
