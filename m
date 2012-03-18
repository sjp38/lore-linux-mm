Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 0AAEB6B004A
	for <linux-mm@kvack.org>; Sun, 18 Mar 2012 18:09:53 -0400 (EDT)
Received: by wgbds10 with SMTP id ds10so523237wgb.26
        for <linux-mm@kvack.org>; Sun, 18 Mar 2012 15:09:52 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120318220751.GD6589@ZenIV.linux.org.uk>
References: <20120318190744.GA6589@ZenIV.linux.org.uk> <CA+55aFwBEoD167oD=X9d6jR+wn6Tb-QFgZR+wGwdej4qakCMgg@mail.gmail.com>
 <20120318220610.GC6589@ZenIV.linux.org.uk> <20120318220751.GD6589@ZenIV.linux.org.uk>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Sun, 18 Mar 2012 15:09:32 -0700
Message-ID: <CA+55aFz-hTQ88fq3_PGSX2UmvxPHm0+vTQYM0nV1_a-u0q-BOQ@mail.gmail.com>
Subject: Re: [rfc][patches] fix for munmap/truncate races
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sun, Mar 18, 2012 at 3:07 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>>
>> Nope - ia64 check explicitly for precisely that case:
> [snip]
> ... and everything else doesn't look at start or end at all.

Ok, then I don't really care, and it certainly simplifies the calling
conventions.

                   Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
