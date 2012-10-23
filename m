Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id DEE966B0044
	for <linux-mm@kvack.org>; Tue, 23 Oct 2012 16:39:53 -0400 (EDT)
Date: Tue, 23 Oct 2012 20:39:52 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: CK2 [09/15] slab: Common name for the per node structures
In-Reply-To: <CAAmzW4OaXvF1LYrh56XOMs+u33KX+dGQ_fsqpRtR1_LmSod_-A@mail.gmail.com>
Message-ID: <0000013a8f5a5494-bbc97834-a344-443e-9709-453a6462a9cf-000000@email.amazonses.com>
References: <20121019142254.724806786@linux.com> <0000013a79802816-21b3fa95-f2af-4fa0-8f06-2ba25de20443-000000@email.amazonses.com> <CAAmzW4OaXvF1LYrh56XOMs+u33KX+dGQ_fsqpRtR1_LmSod_-A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: JoonSoo Kim <js1304@gmail.com>
Cc: Pekka Enberg <penberg@kernel.org>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, elezegarcia@gmail.com

On Sun, 21 Oct 2012, JoonSoo Kim wrote:

> How about changing local variable name 'l3' to 'n' like as slub.c?
> With this patch, 'l3' is somehow strange name.

Ok. Will do that when I have time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
