Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 50A9A82997
	for <linux-mm@kvack.org>; Fri, 22 May 2015 09:14:58 -0400 (EDT)
Received: by paza2 with SMTP id a2so10300893paz.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 06:14:58 -0700 (PDT)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id gq8si3417389pbc.83.2015.05.22.06.14.57
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 06:14:57 -0700 (PDT)
Received: by pdbnk13 with SMTP id nk13so19464999pdb.1
        for <linux-mm@kvack.org>; Fri, 22 May 2015 06:14:57 -0700 (PDT)
Date: Fri, 22 May 2015 22:14:47 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] zram: check compressor name before setting it
Message-ID: <20150522131447.GA14922@blaptop>
References: <1432283515-2005-1-git-send-email-m.jabrzyk@samsung.com>
 <20150522085523.GA709@swordfish>
 <555EF30C.60108@samsung.com>
 <20150522124411.GA3793@swordfish>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150522124411.GA3793@swordfish>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Marcin Jabrzyk <m.jabrzyk@samsung.com>, ngupta@vflare.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com

Hello Sergey,

On Fri, May 22, 2015 at 09:44:11PM +0900, Sergey Senozhatsky wrote:
> On (05/22/15 11:12), Marcin Jabrzyk wrote:
> > >
> > >no.
> > >
> > >zram already complains about failed comp backend creation.
> > >it's in dmesg (or syslog, etc.):
> > >
> > >	"zram: Cannot initialise %s compressing backend"
> > >
> > OK, now I see that. Sorry for the noise.
> > 
> > >second, there is not much value in exposing zcomp internals,
> > >especially when the result is just another line in dmesg output.
> > 
> > From the other hand, the only valid values that can be written are
> > in 'comp_algorithm'.
> > So when writing other one, returning -EINVAL seems to be reasonable.
> > The user would get immediately information that he can't do that,
> > now the information can be very deferred in time.
> 
> it's not.
> the error message appears in syslog right before we return -EINVAL
> back to user.

Although Marcin's description is rather misleading, I like the patch.
Every admin doesn't watch dmesg output. Even people could change loglevel
simply so KERN_INFO would be void in that case.

Instant error propagation is more strighforward for user point of view
rather than delaying with depending on another event.

Thanks.

> 
> 	-ss
> 
> > I'm not for exposing more internals, but getting -EINVAL would be nice I

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
