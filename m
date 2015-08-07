Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 7539D6B0038
	for <linux-mm@kvack.org>; Thu,  6 Aug 2015 23:30:48 -0400 (EDT)
Received: by qged69 with SMTP id d69so67269075qge.0
        for <linux-mm@kvack.org>; Thu, 06 Aug 2015 20:30:48 -0700 (PDT)
Received: from smtp.variantweb.net (smtp.variantweb.net. [104.131.104.118])
        by mx.google.com with ESMTPS id m77si15624652qgm.53.2015.08.06.20.30.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Aug 2015 20:30:47 -0700 (PDT)
Date: Thu, 6 Aug 2015 22:30:43 -0500
From: Seth Jennings <sjennings@variantweb.net>
Subject: Re: [PATCH 1/3] zpool: add zpool_has_pool()
Message-ID: <20150807033043.GA10018@cerebellum.local.variantweb.net>
References: <1438782403-29496-1-git-send-email-ddstreet@ieee.org>
 <1438782403-29496-2-git-send-email-ddstreet@ieee.org>
 <20150805130836.16c42cd0a9fe6f4050cf0620@linux-foundation.org>
 <CALZtONDNYyKEdk2fc40ePH4Y+vOcUE-D7OG1DRekgSxLgVYKeA@mail.gmail.com>
 <20150805150659.eefc5ff531741ab34f48b330@linux-foundation.org>
 <20150806215023.GA8670@cerebellum.local.variantweb.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150806215023.GA8670@cerebellum.local.variantweb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dan Streetman <ddstreet@ieee.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Thu, Aug 06, 2015 at 04:50:23PM -0500, Seth Jennings wrote:
> On Wed, Aug 05, 2015 at 03:06:59PM -0700, Andrew Morton wrote:
> > On Wed, 5 Aug 2015 18:00:26 -0400 Dan Streetman <ddstreet@ieee.org> wrote:
> > 
> > > >
> > > > If there's some reason why this can't happen, can we please have a code
> > > > comment which reveals that reason?
> > > 
> > > zpool_create_pool() should work if this returns true, unless as you
> > > say the module is rmmod'ed *and* removed from the system - since
> > > zpool_create_pool() will call request_module() just as this function
> > > does.  I can add a comment explaining that.
> > 
> > I like comments ;)
> > 
> > Seth, I'm planning on sitting on these patches until you've had a
> > chance to review them.
> 
> Thanks Andrew.  I'm reviewing now.  Patch 2/3 is pretty huge.  I've got
> the gist of the changes now.  I'm also building and testing for myself
> as this creates a lot more surface area for issues, alternating between
> compressors and allocating new compression transforms on the fly.
> 
> I'm kinda with Sergey on this in that it adds yet another complexity to
> an already complex feature.  This adds more locking, more RCU, more
> refcounting.  It's becoming harder to review, test, and verify.
> 
> I should have results tomorrow.

So I gave it a test run turning all the knobs (compressor, enabled,
max_pool_percent, and zpool) like a crazy person and it was stable,
and all the adjustments had the expected result.

Dan, you might follow up with an update to Documentation/vm/zswap.txt
noting that these parameters are runtime adjustable now.

The growing complexity is a concern, but it is nice to have the
flexibility.  Thanks for the good work!

To patchset:

Acked-by: Seth Jennings <sjennings@variantweb.net>

> 
> Thanks,
> Seth

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
