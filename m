Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 7C2C96B0072
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 17:40:18 -0400 (EDT)
Date: Tue, 23 Oct 2012 21:40:17 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: CK2 [04/15] slab: Use the new create_boot_cache function to
 simplify bootstrap
In-Reply-To: <5084FF48.9040001@parallels.com>
Message-ID: <0000013a8f91a2e7-c8201c56-d66b-4865-9070-596217a8f88e-000000@email.amazonses.com>
References: <20121019142254.724806786@linux.com> <0000013a7979e9c4-0f9a8d4b-34b4-45dd-baff-a4ccac7a51a6-000000@email.amazonses.com> <5084FF48.9040001@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

On Mon, 22 Oct 2012, Glauber Costa wrote:

> With this, plus the statement in setup_cpu_cache, it is possible that we
> set the state to PARTIAL from two different locations. Although it
> wouldn't be the first instance of it, I can't say I am a big fan.
>
> Is there any reason why you need to initialize the state to PARTIAL from
> two different locations?

No reason that I can think of. Was useful for me to think things through.
Lets just drop the one that I added. Runs with without it.

> I would just just get rid of the second and keep this one, which is
> called early enough and unconditionally.
>
> > +	} else
> > +	if (slab_state == PARTIAL) {
> > +		/*
>
> } else if ...

Ok also fixed up.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
