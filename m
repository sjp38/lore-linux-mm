Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 5BE8D6B0031
	for <linux-mm@kvack.org>; Fri, 12 Jul 2013 09:58:33 -0400 (EDT)
Date: Fri, 12 Jul 2013 13:58:32 +0000
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm/slub.c: beautify code of this file
In-Reply-To: <51DF778B.8090701@asianux.com>
Message-ID: <0000013fd32d0b91-4cab82b6-a24f-42e2-a1d2-ac5df2be6f4c-000000@email.amazonses.com>
References: <51DF5F43.3080408@asianux.com> <51DF778B.8090701@asianux.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gang <gang.chen@asianux.com>
Cc: Pekka Enberg <penberg@kernel.org>, mpm@selenic.com, linux-mm@kvack.org

On Fri, 12 Jul 2013, Chen Gang wrote:

> Be sure of 80 column limitation for both code and comments.
> Correct tab alignment for 'if-else' statement.

Thanks.

> Remove redundancy 'break' statement.

Hmm... I'd rather have the first break removed.

> Remove useless BUG_ON(), since it can never happen.

It may happen if more code is added to that function. Recently the cgroups
thing was added f.e.

Could you separate this out into multiple patches that each do one thing
only?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
