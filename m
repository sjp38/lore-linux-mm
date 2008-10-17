Received: by nf-out-0910.google.com with SMTP id c10so293485nfd.6
        for <linux-mm@kvack.org>; Fri, 17 Oct 2008 05:46:16 -0700 (PDT)
Date: Fri, 17 Oct 2008 16:49:19 +0400
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 19/31] proc: move /proc/slabinfo boilerplate to mm/slub.c,
	mm/slab.c
Message-ID: <20081017124919.GT22653@x200.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: penberg@cs.helsinki.fi, linux-mm@kvack.org, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

