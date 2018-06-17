Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 997C46B02EB
	for <linux-mm@kvack.org>; Sat, 16 Jun 2018 22:15:25 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y8-v6so6652990pfl.17
        for <linux-mm@kvack.org>; Sat, 16 Jun 2018 19:15:25 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g126-v6si9576992pgc.251.2018.06.16.19.15.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 16 Jun 2018 19:15:24 -0700 (PDT)
Date: Sat, 16 Jun 2018 19:15:22 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: XArray -next inclusion request
Message-ID: <20180617021521.GA18455@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org


Hi Stephen,

Please add

git://git.infradead.org/users/willy/linux-dax.git xarray

to linux-next.  It is based on -rc1.  You will find some conflicts
against Dan's current patches to DAX; these are all resolved correctly
in the xarray-20180615 branch which is based on next-20180615.

In a masterstroke of timing, I'm going to be on a plane to Tokyo on
Monday.  If this causes any problems, please just ignore the request
for now and we'll resolve it when I'm available to fix problems.
