Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id F2A176B02B4
	for <linux-mm@kvack.org>; Mon,  7 Aug 2017 13:48:47 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id n83so15315051ywn.10
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 10:48:47 -0700 (PDT)
Received: from mail-qk0-f178.google.com (mail-qk0-f178.google.com. [209.85.220.178])
        by mx.google.com with ESMTPS id t38si2235189ybi.380.2017.08.07.10.48.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Aug 2017 10:48:47 -0700 (PDT)
Received: by mail-qk0-f178.google.com with SMTP id u139so6783816qka.1
        for <linux-mm@kvack.org>; Mon, 07 Aug 2017 10:48:47 -0700 (PDT)
Subject: Re: [RFC][PATCH] mm/slub.c: Allow poisoning to use the fast path
References: <20170804231002.20362-1-labbott@redhat.com>
 <alpine.DEB.2.20.1708070936400.17268@nuc-kabylake>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <559096f0-bf1b-eff1-f0ce-33f53a4df255@redhat.com>
Date: Mon, 7 Aug 2017 10:48:42 -0700
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.20.1708070936400.17268@nuc-kabylake>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Kees Cook <keescook@chromium.org>, Rik van Riel <riel@redhat.com>

On 08/07/2017 07:37 AM, Christopher Lameter wrote:
> On Fri, 4 Aug 2017, Laura Abbott wrote:
> 
>> All slub debug features currently disable the fast path completely.
>> Some features such as consistency checks require this to allow taking of
>> locks. Poisoning and red zoning don't require this and can safely use
>> the per-cpu fast path. Introduce a Kconfig to continue to use the fast
>> path when 'fast' debugging options are enabled. The code will
>> automatically revert to always using the slow path when 'slow' options
>> are enabled.
> 
> Ok I see that the objects are initialized with poisoning and redzoning but
> I do not see that there is fastpath code to actually check the values
> before the object is reinitialized. Is that intentional or am
> I missing something?
> 

Yes, that's intentional here. I see the validation as a separate more
expensive feature. I had a crude patch to do some checks for testing
and I know Daniel Micay had an out of tree patch to do some checks
as well.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
