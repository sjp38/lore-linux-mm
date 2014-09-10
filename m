Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 96A766B0038
	for <linux-mm@kvack.org>; Wed, 10 Sep 2014 10:22:27 -0400 (EDT)
Received: by mail-pd0-f169.google.com with SMTP id fp1so5826186pdb.14
        for <linux-mm@kvack.org>; Wed, 10 Sep 2014 07:22:27 -0700 (PDT)
Received: from qmta03.emeryville.ca.mail.comcast.net (qmta03.emeryville.ca.mail.comcast.net. [2001:558:fe2d:43:76:96:30:32])
        by mx.google.com with ESMTP id qa6si28129913pdb.55.2014.09.10.07.22.26
        for <linux-mm@kvack.org>;
        Wed, 10 Sep 2014 07:22:26 -0700 (PDT)
Date: Wed, 10 Sep 2014 09:22:23 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/sl[aou]b: make kfree() aware of error pointers
In-Reply-To: <alpine.LNX.2.00.1409100702190.5523@pobox.suse.cz>
Message-ID: <alpine.DEB.2.11.1409100921060.32538@gentwo.org>
References: <alpine.LNX.2.00.1409092319370.5523@pobox.suse.cz> <20140909162114.44b3e98cf925f125e84a8a06@linux-foundation.org> <alpine.LNX.2.00.1409100702190.5523@pobox.suse.cz>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jiri Kosina <jkosina@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Carpenter <dan.carpenter@oracle.com>, Theodore Ts'o <tytso@mit.edu>

On Wed, 10 Sep 2014, Jiri Kosina wrote:

> We obviously don't, as such code will be causing explosions. This is meant
> as a prevention of problems such as the one that has just been fixed in
> ext4.

So we actually think that it is okay to pass an error pointer to kfree
and silently ignore that?

Are we thinking about just accepting any pointer in kfree and ignore
invalid ones?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
