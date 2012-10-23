Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx171.postini.com [74.125.245.171])
	by kanga.kvack.org (Postfix) with SMTP id 5EE336B0070
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 16:48:34 -0400 (EDT)
Date: Tue, 23 Oct 2012 20:48:32 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: CK2 [07/15] Common kmalloc slab index determination
In-Reply-To: <508515B4.1090303@parallels.com>
Message-ID: <0000013a8f624485-3e5c3678-4534-4d2c-9546-97d62bbfd6f9-000000@email.amazonses.com>
References: <20121019142254.724806786@linux.com> <0000013a798237ec-faa35541-43fa-4257-b7dc-da955393004f-000000@email.amazonses.com> <508515B4.1090303@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

On Mon, 22 Oct 2012, Glauber Costa wrote:

> It is still unclear to me if the above is really better than
> ilog2(size -1) + 1

Hmmm... We could change that if ilog2 is now supported on all platforms
and works right. That was not the case a couple of years ago (I believe
2008) when I tried to use ilog.

> For that case, gcc seems to generate dec + brs + inc which at some point
> will be faster than walking a jump table. At least for dynamically-sized
> allocations. The code size is definitely smaller, and this is always
> inline... Anyway, this is totally separate.

Indeed I would favor that approach but it did not work out for all
platforms the last time around. Compiler was getting into issues to do the
constant folding too.

> The patch also seem to have some churn for the slob for no reason: you
> have a patch just to move the kmalloc definitions, would maybe be better
> to do it in there to decrease the # of changes in this one, which is
> more complicated.

Ok. Will look at that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
