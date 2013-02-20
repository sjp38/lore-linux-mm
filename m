Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id 45EFE6B0002
	for <linux-mm@kvack.org>; Wed, 20 Feb 2013 09:22:59 -0500 (EST)
Received: by mail-ie0-f175.google.com with SMTP id c12so9777636ieb.20
        for <linux-mm@kvack.org>; Wed, 20 Feb 2013 06:22:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <5124C6CF.1020001@gmail.com>
References: <1359699013-7160-1-git-send-email-hannes@cmpxchg.org>
	<5124C6CF.1020001@gmail.com>
Date: Wed, 20 Feb 2013 22:22:58 +0800
Message-ID: <CANN689FizixMWu7hKMV055=SY_Sg1rmYrB_KAEwOBP1tEOZw+Q@mail.gmail.com>
Subject: Re: [patch] mm: mlock: document scary-looking stack expansion mlock chain
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ric Mason <ric.masonn@gmail.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Feb 20, 2013 at 8:51 PM, Ric Mason <ric.masonn@gmail.com> wrote:
> On 02/01/2013 02:10 PM, Johannes Weiner wrote:
>>
>> The fact that mlock calls get_user_pages, and get_user_pages might
>> call mlock when expanding a stack looks like a potential recursion.
>
> Why expand stack need call mlock? I can't find it in the codes, could you
> point out to me?

Its hidden in find_expand_vma(). Basically if the existing stack is
already mlocked, any additional stack expansions get mlocked as well.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
