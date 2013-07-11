Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx109.postini.com [74.125.245.109])
	by kanga.kvack.org (Postfix) with SMTP id 66D0B6B0034
	for <linux-mm@kvack.org>; Thu, 11 Jul 2013 02:51:47 -0400 (EDT)
Message-ID: <51DE55C9.1060908@asianux.com>
Date: Thu, 11 Jul 2013 14:50:49 +0800
From: Chen Gang <gang.chen@asianux.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/slub.c: remove 'per_cpu' which is useless variable
References: <51DA734B.4060608@asianux.com> <51DE549F.9070505@kernel.org>
In-Reply-To: <51DE549F.9070505@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: cl@linux-foundation.org, mpm@selenic.com, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

On 07/11/2013 02:45 PM, Pekka Enberg wrote:
> Hi,
> 
> On 07/08/2013 11:07 AM, Chen Gang wrote:
>> Remove 'per_cpu', since it is useless now after the patch: "205ab99
>> slub: Update statistics handling for variable order slabs".
> 
> Whoa, that's a really old commit. Christoph?
> 

Hmm..., waiting discussing result...  :-)

>> Also beautify code with tab alignment.
> 
> That needs to be a separate patch.

OK, I should send it after get result from above discussion.


Thanks.
-- 
Chen Gang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
