Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id B3DCB6B0031
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 20:44:02 -0400 (EDT)
Message-ID: <51E73A16.8070406@asianux.com>
Date: Thu, 18 Jul 2013 08:43:02 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/slub.c: add parameter length checking for alloc_loc_track()
References: <51DA734B.4060608@asianux.com> <51DE549F.9070505@kernel.org> <51DE55C9.1060908@asianux.com> <0000013fce9f5b32-7d62f3c5-bb35-4dd9-ab19-d72bae4b5bdc-000000@email.amazonses.com> <51DEF935.4040804@kernel.org> <0000013fcf608df8-457e2029-51f9-4e49-9992-bf399a97d953-000000@email.amazonses.com> <51DF4540.8060700@asianux.com> <51DF4C94.3060103@asianux.com> <51DF5404.4060004@asianux.com> <0000013fd3250e40-1832fd38-ede3-41af-8fe3-5a0c10f5e5ce-000000@email.amazonses.com> <51E33F98.8060201@asianux.com> <0000013fe2e73e30-817f1bdb-8dc7-4f7b-9b60-b42d5d244fda-000000@email.amazonses.com> <51E49BDF.30008@asianux.com> <0000013fed280250-85b17e35-d4d4-468d-abed-5b2e29cedb94-000000@email.amazonses.com>
In-Reply-To: <0000013fed280250-85b17e35-d4d4-468d-abed-5b2e29cedb94-000000@email.amazonses.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, mpm@selenic.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On 07/17/2013 11:03 PM, Christoph Lameter wrote:
> On Tue, 16 Jul 2013, Chen Gang wrote:
> 
>> Hmm... what you says above is reasonable.
>>
>> In this case, since alloc_loc_track() is a static function, it will
>> depend on the related maintainers' willing and opinions to decide
>> whether add the related check or not (just like add 'BUG_ON' or not).
>>
>> I need respect the original related maintainers' willing and opinions.
> 
> You are talking to the author of the code.
> 

Firstly, at least, my this patch is really useless.

Hmm... when anybody says "need respect original authors' willing and
opinions", I think it often means we have found the direct issue, but
none of us find the root issue.

e.g. for our this case:
  the direct issue is:
    "whether need check the length with 'max' parameter".
  but maybe the root issue is:
    "whether use 'size' as related parameter name instead of 'max'".
    in alloc_loc_track(), 'max' just plays the 'size' role.


Thanks.
-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
