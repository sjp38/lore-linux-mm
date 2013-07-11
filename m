Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id DDE396B0081
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 14:28:08 -0400 (EDT)
Received: by mail-la0-f51.google.com with SMTP id fq12so7003958lab.38
        for <linux-mm@kvack.org>; Thu, 11 Jul 2013 11:28:07 -0700 (PDT)
Message-ID: <51DEF935.4040804@kernel.org>
Date: Thu, 11 Jul 2013 21:28:05 +0300
From: Pekka Enberg <penberg@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/slub.c: remove 'per_cpu' which is useless variable
References: <51DA734B.4060608@asianux.com> <51DE549F.9070505@kernel.org> <51DE55C9.1060908@asianux.com> <0000013fce9f5b32-7d62f3c5-bb35-4dd9-ab19-d72bae4b5bdc-000000@email.amazonses.com>
In-Reply-To: <0000013fce9f5b32-7d62f3c5-bb35-4dd9-ab19-d72bae4b5bdc-000000@email.amazonses.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Chen Gang <gang.chen@asianux.com>, mpm@selenic.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On 7/11/13 7:45 PM, Christoph Lameter wrote:
> On Thu, 11 Jul 2013, Chen Gang wrote:
>
>> On 07/11/2013 02:45 PM, Pekka Enberg wrote:
>>> Hi,
>>>
>>> On 07/08/2013 11:07 AM, Chen Gang wrote:
>>>> Remove 'per_cpu', since it is useless now after the patch: "205ab99
>>>> slub: Update statistics handling for variable order slabs".
>>>
>>> Whoa, that's a really old commit. Christoph?
>
> Gosh we have some code duplication there. Patch mismerged?

What duplication are you referring to?

			Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
