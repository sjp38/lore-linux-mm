Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 178716B005A
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 09:49:34 -0400 (EDT)
Date: Thu, 23 Aug 2012 13:49:32 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: C12 [12/19] Move kmem_cache allocations into common code.
In-Reply-To: <5035DF2E.2010101@parallels.com>
Message-ID: <0000013953bebca6-5a541bae-58b7-4a3c-a3c2-69cc7bb9c04b-000000@email.amazonses.com>
References: <20120820204021.494276880@linux.com> <0000013945cd2d87-d71d0827-51b3-4c98-890f-12beb8ecc72b-000000@email.amazonses.com> <50337722.3040908@parallels.com> <000001394afa9429-b8219750-1ae1-45f2-be1b-e02054615021-000000@email.amazonses.com>
 <50349B70.1050208@parallels.com> <000001394ef0020a-6778ce80-b864-41f4-a515-458cb0a95e6d-000000@email.amazonses.com> <5035DF2E.2010101@parallels.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On Thu, 23 Aug 2012, Glauber Costa wrote:

> This code is prone to errors, as can be easily seen by the amount of
> interactions it had, all of them with bugs. Our best friend in finding
> those bugs is pinpointing the patch where it happens. Please make it easy.

Yes this is pretty key stuff and I am definitely trying to make it as
clean and easy possible.. I am trying my best but I have a limited time
that I can spend on running tests.

It would help if you could try to understand the code, suggest
improvements and verify that the changes are sane. So far I mostly see
"this aint working" instead of an engagement with the code.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
