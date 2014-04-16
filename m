Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f49.google.com (mail-pb0-f49.google.com [209.85.160.49])
	by kanga.kvack.org (Postfix) with ESMTP id 52D5C6B005C
	for <linux-mm@kvack.org>; Wed, 16 Apr 2014 18:57:33 -0400 (EDT)
Received: by mail-pb0-f49.google.com with SMTP id jt11so11364609pbb.22
        for <linux-mm@kvack.org>; Wed, 16 Apr 2014 15:57:32 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id uc7si1732982pbc.389.2014.04.16.15.57.32
        for <linux-mm@kvack.org>;
        Wed, 16 Apr 2014 15:57:32 -0700 (PDT)
Date: Wed, 16 Apr 2014 15:57:30 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 0/N patch emails - to use or not to use?
Message-Id: <20140416155730.b2dc1a551307f736438a85d7@linux-foundation.org>
In-Reply-To: <CALZtONCR-ewaZjmZ_CznwqtGvzkmdTC0hQbbm2YDaSBvWv8XqA@mail.gmail.com>
References: <CALZtONCR-ewaZjmZ_CznwqtGvzkmdTC0hQbbm2YDaSBvWv8XqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Linux-MM <linux-mm@kvack.org>

On Sat, 12 Apr 2014 17:23:31 -0400 Dan Streetman <ddstreet@ieee.org> wrote:

> Hi Andrew,
> 
> I noticed in your The Perfect Patch doc:
> http://www.ozlabs.org/~akpm/stuff/tpp.txt
> Section 6b says you don't like 0/N patch series description-only
> emails.  Is that still true?  Because it seems the majority of patch
> series do include a 0/N descriptive email...

hm, I think what I said about git there isn't true - merge commits can
contain changelogs.

Whatever.  0/n is OK and is more email-reader-friendly.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
