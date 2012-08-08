Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 31BE26B005D
	for <linux-mm@kvack.org>; Wed,  8 Aug 2012 11:13:56 -0400 (EDT)
Message-ID: <1344438832.2832.1.camel@lorien2>
Subject: Re: [PATCH RESEND] mm: Restructure kmem_cache_create() to move
 debug cache integrity checks into a new function
From: Shuah Khan <shuah.khan@hp.com>
Reply-To: shuah.khan@hp.com
Date: Wed, 08 Aug 2012 09:13:52 -0600
In-Reply-To: <alpine.DEB.2.02.1208080913290.7048@greybox.home>
References: <1342221125.17464.8.camel@lorien2>
	 <CAOJsxLGjnMxs9qERG5nCfGfcS3jy6Rr54Ac36WgVnOtP_pDYgQ@mail.gmail.com>
	 <1344224494.3053.5.camel@lorien2> <1344266096.2486.17.camel@lorien2>
	 <CAAmzW4Ne5pD90r+6zrrD-BXsjtf5OqaKdWY+2NSGOh1M_sWq4g@mail.gmail.com>
	 <1344272614.2486.40.camel@lorien2>
	 <alpine.DEB.2.02.1208080913290.7048@greybox.home>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Christoph Lameter (Open Source)" <cl@linux.com>
Cc: JoonSoo Kim <js1304@gmail.com>, Pekka Enberg <penberg@kernel.org>, glommer@parallels.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, David Rientjes <rientjes@google.com>, shuah.khan@hp.com

On Wed, 2012-08-08 at 09:14 -0500, Christoph Lameter (Open Source)
wrote:
> On Mon, 6 Aug 2012, Shuah Khan wrote:
> 
> > No reason, just something I am used to doing :) inline is a good idea. I
> > can fix that easily and send v2 patch.
> 
> Leave that to the compiler. There is no performance reason that would
> give a benefit from forcing inline.
> 

Already fixed in the v2 patch.

Thanks,
-- Shuah

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
