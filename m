Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 39F15280256
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 18:17:03 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 83so15466569pfx.1
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 15:17:03 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 18si11896857pfh.177.2016.11.03.15.17.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Nov 2016 15:17:02 -0700 (PDT)
Date: Thu, 3 Nov 2016 15:17:00 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] z3fold: make pages_nr atomic
Message-Id: <20161103151700.73a98155238acff3f3f98e8b@linux-foundation.org>
In-Reply-To: <CAMJBoFOJqSk+KE8y_jtvGe5TBHevei7ZRjg93tvb1MuqaO9BZg@mail.gmail.com>
References: <20161103220058.3017148c790b352c0ec521d4@gmail.com>
	<20161103141404.2bb6b59435e560f0b82c0a18@linux-foundation.org>
	<CAMJBoFOJqSk+KE8y_jtvGe5TBHevei7ZRjg93tvb1MuqaO9BZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vitaly Wool <vitalywool@gmail.com>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dan Streetman <ddstreet@ieee.org>

On Thu, 3 Nov 2016 22:24:07 +0100 Vitaly Wool <vitalywool@gmail.com> wrote:

> On Thu, Nov 3, 2016 at 10:14 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> > On Thu, 3 Nov 2016 22:00:58 +0100 Vitaly Wool <vitalywool@gmail.com> wrote:
> >
> >> This patch converts pages_nr per-pool counter to atomic64_t.
> >
> > Which is slower.
> >
> > Presumably there is a reason for making this change.  This reason
> > should be described in the changelog.
> 
> The reason [which I thought was somewhat obvious :) ] is that there
> won't be a need to take a per-pool lock to read or modify that
> counter.

But the patch didn't change the locking.  And as far as I can tell,
neither does "z3fold: extend compaction function".

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
