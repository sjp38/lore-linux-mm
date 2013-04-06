Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 7F5C46B013F
	for <linux-mm@kvack.org>; Sat,  6 Apr 2013 05:01:34 -0400 (EDT)
Received: by mail-bk0-f48.google.com with SMTP id jf3so2413950bkc.21
        for <linux-mm@kvack.org>; Sat, 06 Apr 2013 02:01:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <0000013dc73c284d-29fd15db-416b-40cc-81b6-81abc5bd3c02-000000@email.amazonses.com>
References: <CAKb7UviwOk9asT=WxYgDUzfm3J+tGXobroUycpoTvzOX5kkofQ@mail.gmail.com>
	<0000013dc73c284d-29fd15db-416b-40cc-81b6-81abc5bd3c02-000000@email.amazonses.com>
Date: Sat, 6 Apr 2013 05:01:32 -0400
Message-ID: <CAKb7Uvgxm7ouX0AvPo=eLGn_ruJK7FMCaEMVyK8HxhQ3Ekk0sQ@mail.gmail.com>
Subject: Re: system death under oom - 3.7.9
From: Ilia Mirkin <imirkin@alum.mit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, nouveau@lists.freedesktop.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org

On Mon, Apr 1, 2013 at 4:14 PM, Christoph Lameter <cl@linux.com> wrote:
> On Wed, 27 Mar 2013, Ilia Mirkin wrote:
>
>> The GPF happens at +160, which is in the argument setup for the
>> cmpxchg in slab_alloc_node. I think it's the call to
>> get_freepointer(). There was a similar bug report a while back,
>> https://lkml.org/lkml/2011/5/23/199, and the recommendation was to run
>> with slub debugging. Is that still the case, or is there a simpler
>> explanation? I can't reproduce this at will, not sure how many times
>> this has happened but definitely not many.
>
> slub debugging will help to track down the cause of the memory corruption.

OK, with slub_debug=FZP, I get (after a while):

http://pastebin.com/cbHiKhdq

Which definitely makes it look like something in the nouveau
context/whatever alloc failure path causes some stomping to happen. (I
don't suppose it's reasonable to warn when the stomping happens
through some sort of page protection... would explode the size since
each n-byte object would be at least 4K, but might be worth it for
debugging...)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
