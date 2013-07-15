Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx194.postini.com [74.125.245.194])
	by kanga.kvack.org (Postfix) with SMTP id BC9F66B0070
	for <linux-mm@kvack.org>; Sun, 14 Jul 2013 20:09:20 -0400 (EDT)
Message-ID: <51E33D75.9030404@asianux.com>
Date: Mon, 15 Jul 2013 08:08:21 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] mm/slub.c: remove 'per_cpu' which is useless variable
References: <51DA734B.4060608@asianux.com> <51DE549F.9070505@kernel.org> <51DE55C9.1060908@asianux.com> <0000013fce9f5b32-7d62f3c5-bb35-4dd9-ab19-d72bae4b5bdc-000000@email.amazonses.com> <51DEF935.4040804@kernel.org> <0000013fcf608df8-457e2029-51f9-4e49-9992-bf399a97d953-000000@email.amazonses.com> <51DF4540.8060700@asianux.com> <51DF4C94.3060103@asianux.com> <0000013fd32114a7-6d601dfe-1d70-46cc-aa10-7d2898f5ceec-000000@email.amazonses.com>
In-Reply-To: <0000013fd32114a7-6d601dfe-1d70-46cc-aa10-7d2898f5ceec-000000@email.amazonses.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, mpm@selenic.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On 07/12/2013 09:45 PM, Christoph Lameter wrote:
> On Fri, 12 Jul 2013, Chen Gang wrote:
> 
>> Remove 'per_cpu', since it is useless now after the patch: "205ab99
>> slub: Update statistics handling for variable order slabs". And the
>> partial list is handled in the same way as the per cpu slab.
> 
> Acked-by: Christoph Lameter <cl@linux.com>
> 
> 

Thanks.

-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
