Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f78.google.com (mail-oa0-f78.google.com [209.85.219.78])
	by kanga.kvack.org (Postfix) with ESMTP id 264406B0031
	for <linux-mm@kvack.org>; Fri, 20 Dec 2013 15:39:47 -0500 (EST)
Received: by mail-oa0-f78.google.com with SMTP id m1so40337oag.5
        for <linux-mm@kvack.org>; Fri, 20 Dec 2013 12:39:46 -0800 (PST)
Received: from qmta11.emeryville.ca.mail.comcast.net (qmta11.emeryville.ca.mail.comcast.net. [2001:558:fe2d:44:76:96:27:211])
        by mx.google.com with ESMTP id t7si3142052qar.107.2013.12.19.07.41.52
        for <linux-mm@kvack.org>;
        Thu, 19 Dec 2013 07:41:54 -0800 (PST)
Date: Thu, 19 Dec 2013 09:41:50 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: Re: bad page state in 3.13-rc4
In-Reply-To: <CA+55aFwweoGs3eGWXFULcqnbRbpDhpj2qrefXB5OpQOiWW8wYA@mail.gmail.com>
Message-ID: <alpine.DEB.2.10.1312190930190.4238@nuc>
References: <20131219040738.GA10316@redhat.com> <CA+55aFwweoGs3eGWXFULcqnbRbpDhpj2qrefXB5OpQOiWW8wYA@mail.gmail.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Wed, 18 Dec 2013, Linus Torvalds wrote:

> Somebody who knows the migration code needs to look at this. ChristophL?

Its been awhile sorry and there has been a huge amount of work done on top
of my earlier work. Cannot debug that anymore and I am finding myself in
the role of the old guy who just complains a lot. Some of that
functionality seems bizarre to me like the on the fly conversion between
huge pages and regular pages, weird and complex page count handling etc
etc.

The last time I looked at the code I was horrified to find that the new
huge page migration does not use migration ptes to create a cooldown phase
but directly swaps the pmd. That used to cause huge problems with regular
pages in the past. But I was told that was all safe. Mel?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
