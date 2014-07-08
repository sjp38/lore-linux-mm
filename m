Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f54.google.com (mail-la0-f54.google.com [209.85.215.54])
	by kanga.kvack.org (Postfix) with ESMTP id 12D4F6B0031
	for <linux-mm@kvack.org>; Tue,  8 Jul 2014 16:40:19 -0400 (EDT)
Received: by mail-la0-f54.google.com with SMTP id mc6so4322447lab.41
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 13:40:19 -0700 (PDT)
Received: from mail-lb0-x22f.google.com (mail-lb0-x22f.google.com [2a00:1450:4010:c04::22f])
        by mx.google.com with ESMTPS id ll12si26691236lac.83.2014.07.08.13.40.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 08 Jul 2014 13:40:18 -0700 (PDT)
Received: by mail-lb0-f175.google.com with SMTP id n15so4318137lbi.20
        for <linux-mm@kvack.org>; Tue, 08 Jul 2014 13:40:18 -0700 (PDT)
Date: Wed, 9 Jul 2014 00:40:17 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: Don't forget to set softdirty on file mapped fault
Message-ID: <20140708204017.GG17860@moon.sw.swsoft.com>
References: <20140708192151.GD17860@moon.sw.swsoft.com>
 <20140708131920.2a857d573e8cc89780c9fa1c@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140708131920.2a857d573e8cc89780c9fa1c@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Pavel Emelyanov <xemul@parallels.com>

On Tue, Jul 08, 2014 at 01:19:20PM -0700, Andrew Morton wrote:
> On Tue, 8 Jul 2014 23:21:51 +0400 Cyrill Gorcunov <gorcunov@gmail.com> wrote:
> 
> > Otherwise we may not notice that pte was softdirty because pte_mksoft_dirty
> > helper _returns_ new pte but not modifies argument.
> 
> When fixing a bug, please describe the end-user visible effects of that
> bug.
> 
> [for the 12,000th time :(]

"we may not notice that pte was softdirty" I thought it's enough, because
that's the effect user sees -- pte is not dirtified where it should.

Really sorry Andrew if I were not clear enough. What about: In case if page
fault happend on dirty filemapping the newly created pte may not
notice if old one were already softdirtified because pte_mksoft_dirty
doesn't modify its argument but rather returns new pte value.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
