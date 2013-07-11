Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id D2BA56B0032
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 19:53:32 -0400 (EDT)
Message-ID: <51DF4540.8060700@asianux.com>
Date: Fri, 12 Jul 2013 07:52:32 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/slub.c: remove 'per_cpu' which is useless variable
References: <51DA734B.4060608@asianux.com> <51DE549F.9070505@kernel.org> <51DE55C9.1060908@asianux.com> <0000013fce9f5b32-7d62f3c5-bb35-4dd9-ab19-d72bae4b5bdc-000000@email.amazonses.com> <51DEF935.4040804@kernel.org> <0000013fcf608df8-457e2029-51f9-4e49-9992-bf399a97d953-000000@email.amazonses.com>
In-Reply-To: <0000013fcf608df8-457e2029-51f9-4e49-9992-bf399a97d953-000000@email.amazonses.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, mpm@selenic.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On 07/12/2013 04:16 AM, Christoph Lameter wrote:
> On Thu, 11 Jul 2013, Pekka Enberg wrote:
> 
>>> Gosh we have some code duplication there. Patch mismerged?
>>
>> What duplication are you referring to?
> 
> Sorry, no duplicate. The partial list is handled in the same way as the
> per cpu slab. Yep its ok to remove. Chen: Clean up your patches and then
> we can merge them.
> 

OK, thanks. I should send patch v2 for it.

Thanks.
-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
