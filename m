Received: by nf-out-0910.google.com with SMTP id c10so293485nfd.6
        for <linux-mm@kvack.org>; Fri, 17 Oct 2008 05:45:50 -0700 (PDT)
Date: Fri, 17 Oct 2008 16:48:54 +0400
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 18/31] proc: move /proc/slab_allocators boilerplate to
	mm/slab.c
Message-ID: <20081017124854.GS22653@x200.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: penberg@cs.helsinki.fi, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

