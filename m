Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 7B5766B0032
	for <linux-mm@kvack.org>; Wed, 14 Aug 2013 11:28:25 -0400 (EDT)
Message-ID: <520BA215.6010207@iki.fi>
Date: Wed, 14 Aug 2013 18:28:21 +0300
From: Pekka Enberg <penberg@iki.fi>
MIME-Version: 1.0
Subject: Re: [3.12 1/3] Move kmallocXXX functions to common code
References: <20130813154940.741769876@linux.com> <00000140785e1062-89326db9-3999-43c1-b081-284dd49b3d9b-000000@email.amazonses.com> <520B9A0E.4020009@fastmail.fm>
In-Reply-To: <520B9A0E.4020009@fastmail.fm>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@fastmail.fm>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On 08/14/2013 05:54 PM, Pekka Enberg wrote:
> I already applied an earlier version that's now breaking linux-next.
> Can you please send incremental fixes on top of slab/next?
> I'd prefer not to rebase...

Ok, I rebased anyway and dropped the broken commits. I'm not
happy that this bundles kmalloc_large(), though, so it needs to
be taken out for me to merge this.

                         Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
