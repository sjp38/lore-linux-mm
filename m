Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 7AE4B6B0036
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 02:37:01 -0400 (EDT)
Received: by mail-pa0-f41.google.com with SMTP id bj1so5757407pad.0
        for <linux-mm@kvack.org>; Tue, 09 Sep 2014 23:37:00 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id fn1si26122729pbb.223.2014.09.09.23.36.59
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 09 Sep 2014 23:37:00 -0700 (PDT)
Date: Wed, 10 Sep 2014 09:36:30 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] mm/sl[aou]b: make kfree() aware of error pointers
Message-ID: <20140910063630.GM6549@mwanda>
References: <alpine.LNX.2.00.1409092319370.5523@pobox.suse.cz>
 <20140909162114.44b3e98cf925f125e84a8a06@linux-foundation.org>
 <alpine.LNX.2.00.1409100702190.5523@pobox.suse.cz>
 <20140909221138.2587d864.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140909221138.2587d864.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jiri Kosina <jkosina@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Theodore Ts'o <tytso@mit.edu>

On Tue, Sep 09, 2014 at 10:11:38PM -0700, Andrew Morton wrote:
> On Wed, 10 Sep 2014 07:05:40 +0200 (CEST) Jiri Kosina <jkosina@suse.cz> wrote:
> This is the sort of error which a static checker could find.  I wonder
> if any of them do so.

Yes.  Ted asked me to add this to Smatch and that's how we found the
problems in ext4.  I'll push it out later this week.  It won't find
every single bug.

We have fixed the 8 bugs that Smatch found.

regards,
dan carpenter

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
