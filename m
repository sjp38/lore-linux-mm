Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id F1DB76B0075
	for <linux-mm@kvack.org>; Sun, 14 Jul 2013 20:32:54 -0400 (EDT)
Message-ID: <51E342FC.5060705@asianux.com>
Date: Mon, 15 Jul 2013 08:31:56 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/slub.c: beautify code of this file
References: <51DF5F43.3080408@asianux.com> <51DF778B.8090701@asianux.com> <0000013fd32d0b91-4cab82b6-a24f-42e2-a1d2-ac5df2be6f4c-000000@email.amazonses.com>
In-Reply-To: <0000013fd32d0b91-4cab82b6-a24f-42e2-a1d2-ac5df2be6f4c-000000@email.amazonses.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, mpm@selenic.com, linux-mm@kvack.org

On 07/12/2013 09:58 PM, Christoph Lameter wrote:
> On Fri, 12 Jul 2013, Chen Gang wrote:
> 
>> Be sure of 80 column limitation for both code and comments.
>> Correct tab alignment for 'if-else' statement.
> 
> Thanks.
> 

Thank you too.

>> Remove redundancy 'break' statement.
> 
> Hmm... I'd rather have the first break removed.
> 

Yeah, that will be better for coding and understanding. I will send
patch v2 for it.

>> Remove useless BUG_ON(), since it can never happen.
> 
> It may happen if more code is added to that function. Recently the cgroups
> thing was added f.e.
> 

Hmm... at least what you said is reasonable. I need respect the related
maintainers' willing and opinions (e.g. you for "slub.c").

> Could you separate this out into multiple patches that each do one thing
> only?
> 

OK, thanks. I will do.

Originally, I think these are minor, I should do with them in a patch,
so can save maintainers' time resource (now, I know it is incorrect).

:-)


Thanks.
-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
