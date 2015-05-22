Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 13FA16B026D
	for <linux-mm@kvack.org>; Fri, 22 May 2015 08:43:51 -0400 (EDT)
Received: by pdbqa5 with SMTP id qa5so18984962pdb.0
        for <linux-mm@kvack.org>; Fri, 22 May 2015 05:43:50 -0700 (PDT)
Received: from mail-pd0-x232.google.com (mail-pd0-x232.google.com. [2607:f8b0:400e:c02::232])
        by mx.google.com with ESMTPS id iz4si3221795pbc.245.2015.05.22.05.43.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 05:43:50 -0700 (PDT)
Received: by pdea3 with SMTP id a3so18904216pde.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 05:43:49 -0700 (PDT)
Date: Fri, 22 May 2015 21:44:11 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zram: check compressor name before setting it
Message-ID: <20150522124411.GA3793@swordfish>
References: <1432283515-2005-1-git-send-email-m.jabrzyk@samsung.com>
 <20150522085523.GA709@swordfish>
 <555EF30C.60108@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <555EF30C.60108@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Marcin Jabrzyk <m.jabrzyk@samsung.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, minchan@kernel.org, ngupta@vflare.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kyungmin.park@samsung.com

On (05/22/15 11:12), Marcin Jabrzyk wrote:
> >
> >no.
> >
> >zram already complains about failed comp backend creation.
> >it's in dmesg (or syslog, etc.):
> >
> >	"zram: Cannot initialise %s compressing backend"
> >
> OK, now I see that. Sorry for the noise.
> 
> >second, there is not much value in exposing zcomp internals,
> >especially when the result is just another line in dmesg output.
> 
> From the other hand, the only valid values that can be written are
> in 'comp_algorithm'.
> So when writing other one, returning -EINVAL seems to be reasonable.
> The user would get immediately information that he can't do that,
> now the information can be very deferred in time.

it's not.
the error message appears in syslog right before we return -EINVAL
back to user.

	-ss

> I'm not for exposing more internals, but getting -EINVAL would be nice I

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
