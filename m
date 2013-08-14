Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 9F32A6B0033
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 12:37:56 -0400 (EDT)
Date: Wed, 14 Aug 2013 16:37:55 +0000
From: Christoph Lameter <cl@gentwo.org>
Subject: Re: [3.12 1/3] Move kmallocXXX functions to common code
In-Reply-To: <520B9A0E.4020009@fastmail.fm>
Message-ID: <000001407db0c6ba-78fff117-2dfb-4211-b72e-2d5dc638b377-000000@email.amazonses.com>
References: <20130813154940.741769876@linux.com> <00000140785e1062-89326db9-3999-43c1-b081-284dd49b3d9b-000000@email.amazonses.com> <520B9A0E.4020009@fastmail.fm>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@fastmail.fm>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Wed, 14 Aug 2013, Pekka Enberg wrote:

> I already applied an earlier version that's now breaking linux-next.
> Can you please send incremental fixes on top of slab/next?
> I'd prefer not to rebase...

There is breakage because the first two patches have cross dependencies.
That is the main reason for the new patchset.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
