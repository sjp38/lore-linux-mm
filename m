Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 735C06B0255
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 17:50:57 -0400 (EDT)
Received: by qkdg63 with SMTP id g63so31325554qkd.0
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 14:50:57 -0700 (PDT)
Received: from smtp.variantweb.net (smtp.variantweb.net. [104.131.104.118])
        by mx.google.com with ESMTPS id f124si14188244qhe.90.2015.08.06.14.50.26
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Aug 2015 14:50:56 -0700 (PDT)
Date: Thu, 6 Aug 2015 16:50:23 -0500
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCH 1/3] zpool: add zpool_has_pool()
Message-ID: <20150806215023.GA8670@cerebellum.local.variantweb.net>
References: <1438782403-29496-1-git-send-email-ddstreet@ieee.org>
 <1438782403-29496-2-git-send-email-ddstreet@ieee.org>
 <20150805130836.16c42cd0a9fe6f4050cf0620@linux-foundation.org>
 <CALZtONDNYyKEdk2fc40ePH4Y+vOcUE-D7OG1DRekgSxLgVYKeA@mail.gmail.com>
 <20150805150659.eefc5ff531741ab34f48b330@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150805150659.eefc5ff531741ab34f48b330@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Wed, Aug 05, 2015 at 03:06:59PM -0700, Andrew Morton wrote:
> On Wed, 5 Aug 2015 18:00:26 -0400 Dan Streetman <ddstreet@ieee.org> wrote:
> 
> > >
> > > If there's some reason why this can't happen, can we please have a code
> > > comment which reveals that reason?
> > 
> > zpool_create_pool() should work if this returns true, unless as you
> > say the module is rmmod'ed *and* removed from the system - since
> > zpool_create_pool() will call request_module() just as this function
> > does.  I can add a comment explaining that.
> 
> I like comments ;)
> 
> Seth, I'm planning on sitting on these patches until you've had a
> chance to review them.

Thanks Andrew.  I'm reviewing now.  Patch 2/3 is pretty huge.  I've got
the gist of the changes now.  I'm also building and testing for myself
as this creates a lot more surface area for issues, alternating between
compressors and allocating new compression transforms on the fly.

I'm kinda with Sergey on this in that it adds yet another complexity to
an already complex feature.  This adds more locking, more RCU, more
refcounting.  It's becoming harder to review, test, and verify.

I should have results tomorrow.

Thanks,
Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
