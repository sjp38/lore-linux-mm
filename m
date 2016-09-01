Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 854B06B0038
	for <linux-mm@kvack.org>; Thu,  1 Sep 2016 09:10:46 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id k186so38502985qkb.3
        for <linux-mm@kvack.org>; Thu, 01 Sep 2016 06:10:46 -0700 (PDT)
Received: from sandeen.net (sandeen.net. [63.231.237.45])
        by mx.google.com with ESMTP id d6si6738722oig.35.2016.09.01.06.10.45
        for <linux-mm@kvack.org>;
        Thu, 01 Sep 2016 06:10:45 -0700 (PDT)
Subject: Re: [PATCH] fs:Fix kmemleak leak warning in getname_flags about
 working on unitialized memory
References: <1470260896-31767-1-git-send-email-xerofoify@gmail.com>
 <df8dd6cd-245d-0673-0246-e514b2a67fc2@I-love.SAKURA.ne.jp>
 <20160804135712.GK2356@ZenIV.linux.org.uk>
From: Eric Sandeen <sandeen@sandeen.net>
Message-ID: <f20e389d-2269-9aca-0fd5-019b7a042f9e@sandeen.net>
Date: Thu, 1 Sep 2016 08:10:44 -0500
MIME-Version: 1.0
In-Reply-To: <20160804135712.GK2356@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@ZenIV.linux.org.uk>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, msalter@redhat.com, kuleshovmail@gmail.com, david.vrabel@citrix.com, vbabka@suse.cz, ard.biesheuvel@linaro.org, jgross@suse.com, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 8/4/16 8:57 AM, Al Viro wrote:

> Don't feed the troll.  On all paths leading to that place we have
>         result->name = kname;
>         len = strncpy_from_user(kname, filename, EMBEDDED_NAME_MAX);
> or
>                 result->name = kname;
>                 len = strncpy_from_user(kname, filename, PATH_MAX);
> with failure exits taken if strncpy_from_user() returns an error, which means
> that the damn thing has already been copied into.
> 
> FWIW, it looks a lot like buggered kmemcheck; as usual, he can't be bothered
> to mention which kernel version would it be (let alone how to reproduce it
> on the kernel in question), but IIRC davej had run into some instrumentation
> breakage lately.

The original report is in https://bugzilla.kernel.org/show_bug.cgi?id=120651
if anyone is interested in it.

-Eric

> Again, don't feed the troll - you are only inviting an "improved" version
> of that garbage, just as pointless.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
