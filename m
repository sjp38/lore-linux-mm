Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 0ED1A6B005A
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 10:00:42 -0400 (EDT)
Message-ID: <503636CE.20501@parallels.com>
Date: Thu, 23 Aug 2012 17:57:34 +0400
From: Glauber Costa <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: C12 [12/19] Move kmem_cache allocations into common code.
References: <20120820204021.494276880@linux.com> <0000013945cd2d87-d71d0827-51b3-4c98-890f-12beb8ecc72b-000000@email.amazonses.com> <50337722.3040908@parallels.com> <000001394afa9429-b8219750-1ae1-45f2-be1b-e02054615021-000000@email.amazonses.com> <50349B70.1050208@parallels.com> <000001394ef0020a-6778ce80-b864-41f4-a515-458cb0a95e6d-000000@email.amazonses.com> <5035DF2E.2010101@parallels.com> <0000013953bebca6-5a541bae-58b7-4a3c-a3c2-69cc7bb9c04b-000000@email.amazonses.com>
In-Reply-To: <0000013953bebca6-5a541bae-58b7-4a3c-a3c2-69cc7bb9c04b-000000@email.amazonses.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

On 08/23/2012 05:49 PM, Christoph Lameter wrote:
> On Thu, 23 Aug 2012, Glauber Costa wrote:
> 
>> This code is prone to errors, as can be easily seen by the amount of
>> interactions it had, all of them with bugs. Our best friend in finding
>> those bugs is pinpointing the patch where it happens. Please make it easy.
> 
> Yes this is pretty key stuff and I am definitely trying to make it as
> clean and easy possible.. I am trying my best but I have a limited time
> that I can spend on running tests.
> 

That is understandable. The way to scale that is to have other people
testing the final result, and that is precisely what I am doing.

> It would help if you could try to understand the code, suggest
> improvements and verify that the changes are sane. So far I mostly see
> "this aint working" instead of an engagement with the code.
> 

You can't be serious...
I tested every series you posted. I code reviewed all your iterations so
far. Found a bunch of bugs, debugged all of them up to v11. Pinpointed
to you the exact source of a lot of them, as a result of the
aforementioned debugging.

How isn't it engagement? Seriously?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
