Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id AF14B6B005A
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 10:31:34 -0400 (EDT)
Date: Thu, 23 Aug 2012 14:31:33 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: C12 [12/19] Move kmem_cache allocations into common code.
In-Reply-To: <503636CE.20501@parallels.com>
Message-ID: <0000013953e53070-fc40e386-8f8d-4cca-94a5-cb09952bed5b-000000@email.amazonses.com>
References: <20120820204021.494276880@linux.com> <0000013945cd2d87-d71d0827-51b3-4c98-890f-12beb8ecc72b-000000@email.amazonses.com> <50337722.3040908@parallels.com> <000001394afa9429-b8219750-1ae1-45f2-be1b-e02054615021-000000@email.amazonses.com>
 <50349B70.1050208@parallels.com> <000001394ef0020a-6778ce80-b864-41f4-a515-458cb0a95e6d-000000@email.amazonses.com> <5035DF2E.2010101@parallels.com> <0000013953bebca6-5a541bae-58b7-4a3c-a3c2-69cc7bb9c04b-000000@email.amazonses.com>
 <503636CE.20501@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Thu, 23 Aug 2012, Glauber Costa wrote:

> I tested every series you posted. I code reviewed all your iterations so
> far. Found a bunch of bugs, debugged all of them up to v11. Pinpointed
> to you the exact source of a lot of them, as a result of the
> aforementioned debugging.

Well yes, that debugging and review used to be there in the past but not
in the latest iterations. Bisecting and pointing to the patch does not
require an understanding of the code.

In order to make faster progress it may also be useful to stop at the
patch that is not working for you and ensure that those before are
properly reviewed so that at least those can be merged.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
