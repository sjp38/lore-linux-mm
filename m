Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 67CE16B0038
	for <linux-mm@kvack.org>; Tue, 20 Sep 2016 16:05:32 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id n24so56364484pfb.0
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 13:05:32 -0700 (PDT)
Received: from mail-pa0-x22a.google.com (mail-pa0-x22a.google.com. [2607:f8b0:400e:c03::22a])
        by mx.google.com with ESMTPS id mu9si32028808pab.78.2016.09.20.13.05.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Sep 2016 13:05:31 -0700 (PDT)
Received: by mail-pa0-x22a.google.com with SMTP id id6so10204796pad.3
        for <linux-mm@kvack.org>; Tue, 20 Sep 2016 13:05:31 -0700 (PDT)
Date: Tue, 20 Sep 2016 13:05:27 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm/mempolicy.c: forbid static or relative flags for
 local NUMA mode
In-Reply-To: <20160920155601.GB3899@home>
Message-ID: <alpine.DEB.2.10.1609201304450.134671@chino.kir.corp.google.com>
References: <20160918112943.1645-1-kwapulinski.piotr@gmail.com> <alpine.DEB.2.10.1609191755060.53329@chino.kir.corp.google.com> <20160920155601.GB3899@home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Piotr Kwapulinski <kwapulinski.piotr@gmail.com>
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, vbabka@suse.cz, mhocko@kernel.org, mgorman@techsingularity.net, liangchen.linux@gmail.com, nzimmer@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 20 Sep 2016, Piotr Kwapulinski wrote:

> > There wasn't an MPOL_LOCAL when I introduced either of these flags, it's 
> > an oversight to allow them to be passed.
> > 
> > Want to try to update set_mempolicy(2) with the procedure outlined in 
> > https://www.kernel.org/doc/man-pages/patches.html as well?
> Yes, why not ? I'll put a note about it.
> 

Thanks!  While you're hacking on this area and everything is familiar to 
you, I'm sure the man page would benefit from as extensive update as 
you're willing to do.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
