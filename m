Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id A7DE36B0005
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 11:15:46 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id s7-v6so2800369ybo.4
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 08:15:46 -0700 (PDT)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id 186si4892061qkj.365.2018.04.12.08.15.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 12 Apr 2018 08:15:45 -0700 (PDT)
Date: Thu, 12 Apr 2018 10:15:42 -0500 (CDT)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH v2 2/2] slab: __GFP_ZERO is incompatible with a
 constructor
In-Reply-To: <20180412142718.GA20398@bombadil.infradead.org>
Message-ID: <alpine.DEB.2.20.1804121011350.11710@nuc-kabylake>
References: <20180411060320.14458-1-willy@infradead.org> <20180411060320.14458-3-willy@infradead.org> <alpine.DEB.2.20.1804110842560.3788@nuc-kabylake> <20180411192448.GD22494@bombadil.infradead.org> <alpine.DEB.2.20.1804111601090.7458@nuc-kabylake>
 <20180411235652.GA28279@bombadil.infradead.org> <alpine.DEB.2.20.1804120907100.11220@nuc-kabylake> <20180412142718.GA20398@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Mel Gorman <mgorman@techsingularity.net>

On Thu, 12 Apr 2018, Matthew Wilcox wrote:

> > Thus the next invocation of the fastpath will find that c->freelist is
> > NULL and go to the slowpath. ...
>
> _ah_.  I hadn't figured out that c->page was always NULL in the debugging
> case too, so ___slab_alloc() always hits the 'new_slab' case.  Thanks!

Also note that you can have SLUB also do the build with all debugging on
without having to use a command like parameter (like SLAB). That requires
CONFIG_SLUB_DEBUG_ON to be set. CONFIG_SLUB_DEBUG is set by default for
all distro builds. It only includes the debug code but does not activate
them by default. Kernel command line parameters allow you to selectively
switch on debugging features for specific slab caches so that you can
limit the latency variations introduced by debugging into the production
kernel. Thus subtle races may be found.
