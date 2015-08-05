Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id E51216B0255
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 18:07:01 -0400 (EDT)
Received: by pacrr5 with SMTP id rr5so10711454pac.3
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 15:07:01 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id 1si7488852pde.236.2015.08.05.15.07.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Aug 2015 15:07:01 -0700 (PDT)
Date: Wed, 5 Aug 2015 15:06:59 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] zpool: add zpool_has_pool()
Message-Id: <20150805150659.eefc5ff531741ab34f48b330@linux-foundation.org>
In-Reply-To: <CALZtONDNYyKEdk2fc40ePH4Y+vOcUE-D7OG1DRekgSxLgVYKeA@mail.gmail.com>
References: <1438782403-29496-1-git-send-email-ddstreet@ieee.org>
	<1438782403-29496-2-git-send-email-ddstreet@ieee.org>
	<20150805130836.16c42cd0a9fe6f4050cf0620@linux-foundation.org>
	<CALZtONDNYyKEdk2fc40ePH4Y+vOcUE-D7OG1DRekgSxLgVYKeA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Seth Jennings <sjennings@variantweb.net>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Wed, 5 Aug 2015 18:00:26 -0400 Dan Streetman <ddstreet@ieee.org> wrote:

> >
> > If there's some reason why this can't happen, can we please have a code
> > comment which reveals that reason?
> 
> zpool_create_pool() should work if this returns true, unless as you
> say the module is rmmod'ed *and* removed from the system - since
> zpool_create_pool() will call request_module() just as this function
> does.  I can add a comment explaining that.

I like comments ;)

Seth, I'm planning on sitting on these patches until you've had a
chance to review them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
