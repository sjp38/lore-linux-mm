Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id D8D586B025E
	for <linux-mm@kvack.org>; Sat, 19 Mar 2016 21:55:12 -0400 (EDT)
Received: by mail-wm0-f52.google.com with SMTP id l68so113249671wml.0
        for <linux-mm@kvack.org>; Sat, 19 Mar 2016 18:55:12 -0700 (PDT)
Date: Sun, 20 Mar 2016 01:55:11 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: aio openat Re: [PATCH 07/13] aio: enabled thread based async
 fsync
Message-ID: <20160320015511.GZ17997@ZenIV.linux.org.uk>
References: <20160120195957.GV6033@dastard>
 <CA+55aFx4PzugV+wOKRqMEwo8XJ1QxP8r+s-mvn6H064FROnKdQ@mail.gmail.com>
 <20160120204449.GC12249@kvack.org>
 <20160120214546.GX6033@dastard>
 <CA+55aFzA8cdvYyswW6QddM60EQ8yocVfT4+mYJSoKW9HHf3rHQ@mail.gmail.com>
 <20160123043922.GF6033@dastard>
 <20160314171737.GK17923@kvack.org>
 <CA+55aFx7JJdYNWRSs6Nbm_xyQjgUVoBQh=RuNDeavKS1Jr+-ow@mail.gmail.com>
 <20160320012610.GX17997@ZenIV.linux.org.uk>
 <CA+55aFxW9iWji3hd2PVWoMGeG1O3L5eYPgABEFtU3Cs7vpqXXg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxW9iWji3hd2PVWoMGeG1O3L5eYPgABEFtU3Cs7vpqXXg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Benjamin LaHaise <bcrl@kvack.org>, Dave Chinner <david@fromorbit.com>, Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-aio@kvack.org, linux-mm <linux-mm@kvack.org>

On Sat, Mar 19, 2016 at 06:45:19PM -0700, Linus Torvalds wrote:

> It actually does seem to do that, although in an admittedly rather
> questionable way.
> 
> I think it should use path_openat() rather than do_filp_open(), but
> passing in LOOKUP_RCU to do_filp_open() actually does work: it just
> means that the retry after ECHILD/ESTALE will just do it *again* with
> LOOKUP_RCU. It won't fall back to non-rcu mode, it just won't or in
> the LOOKUP_RCU flag that is already set.

What would make unlazy_walk() fail?  And if it succeeds, you are not
in RCU mode anymore *without* restarting from scratch...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
