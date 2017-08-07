Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9A8AD6B025F
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 18:00:49 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id s26so7490121qts.8
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 15:00:49 -0700 (PDT)
Received: from mail-qt0-f181.google.com (mail-qt0-f181.google.com. [209.85.216.181])
        by mx.google.com with ESMTPS id v2si8247945qtf.184.2017.08.07.15.00.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 15:00:48 -0700 (PDT)
Received: by mail-qt0-f181.google.com with SMTP id 16so10504990qtz.4
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 15:00:48 -0700 (PDT)
Subject: Re: [RFC][PATCH] mm/slub.c: Allow poisoning to use the fast path
References: <20170804231002.20362-1-labbott@redhat.com>
 <alpine.DEB.2.20.1708070936400.17268@nuc-kabylake>
 <559096f0-bf1b-eff1-f0ce-33f53a4df255@redhat.com>
 <alpine.DEB.2.20.1708071302310.18681@nuc-kabylake>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <e0fc8a0a-fa52-e644-1fc2-4e96082858e0@redhat.com>
Date: Mon, 7 Aug 2017 15:00:44 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1708071302310.18681@nuc-kabylake>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>, Rik van Riel <riel@redhat.com>

On 08/07/2017 11:03 AM, Christopher Lameter wrote:
> On Mon, 7 Aug 2017, Laura Abbott wrote:
> 
>>> Ok I see that the objects are initialized with poisoning and redzoning but
>>> I do not see that there is fastpath code to actually check the values
>>> before the object is reinitialized. Is that intentional or am
>>> I missing something?
>>
>> Yes, that's intentional here. I see the validation as a separate more
>> expensive feature. I had a crude patch to do some checks for testing
>> and I know Daniel Micay had an out of tree patch to do some checks
>> as well.
> 
> Ok then this patch does nothing? How does this help?

The purpose of this patch is to ensure the poisoning can happen without
too much penalty. Even if there aren't checks to abort/warn when there
is a problem, there's still value in ensuring objects are always poisoned.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
