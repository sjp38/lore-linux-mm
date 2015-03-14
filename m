Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id C8B696B0085
	for <linux-mm@kvack.org>; Sat, 14 Mar 2015 13:33:31 -0400 (EDT)
Received: by wggv3 with SMTP id v3so10255885wgg.1
        for <linux-mm@kvack.org>; Sat, 14 Mar 2015 10:33:31 -0700 (PDT)
Received: from mail-wi0-x230.google.com (mail-wi0-x230.google.com. [2a00:1450:400c:c05::230])
        by mx.google.com with ESMTPS id y6si8615042wiv.123.2015.03.14.10.33.29
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Mar 2015 10:33:29 -0700 (PDT)
Received: by wifj2 with SMTP id j2so10835020wif.1
        for <linux-mm@kvack.org>; Sat, 14 Mar 2015 10:33:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <a0dcd8d7307e313474d4d721c76bb5a9.squirrel@shrek.krogh.cc>
References: <52ec58f434865829c37337624d124981.squirrel@shrek.krogh.cc>
 <CABYiri81_RAtJizfpOdNPc6m9_Q2u0O35NX0ZhO1cxFpm866HQ@mail.gmail.com> <a0dcd8d7307e313474d4d721c76bb5a9.squirrel@shrek.krogh.cc>
From: Andrey Korolyov <andrey@xdel.ru>
Date: Sat, 14 Mar 2015 20:33:08 +0300
Message-ID: <CABYiri9BcgNEYD5C4qGf=3q6a=d549Rp9rXD7BAo8NkVDAPOqA@mail.gmail.com>
Subject: Re: High system load and 3TB of memory.
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jesper@krogh.cc
Cc: linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christian Marie <christian@ponies.io>

On Sat, Mar 14, 2015 at 8:25 PM,  <jesper@krogh.cc> wrote:
>> On Sat, Mar 14, 2015 at 8:05 PM,  <jesper@krogh.cc> wrote:
>>> Hi
>>> I have a 3.13 (ubuntu LTS) server with 3TB of memory and under certain
>>> load
>>> conditions it can spiral off to 80+% system load. Per recommendation on
>>> IRC
>>> yesterday I have captured 2 perf reports (I'm new to perf, so I'm not
>>> sure they tell precisely whats needed.
>>>
>>> Bad situation (high sysload 80%+)
>
>
>> Hi Jesper, please take a look on
>> http://marc.info/?l=linux-mm&m=141605213522925&w=2, there is a long
>> and unfinished discussion as it seems very problematic to make a
>> deterministic reproduction of the bug in our environments. If you can
>> observe same lockups with more ease, it`ll help a lot in the issue
>> pinning and fixing.
>
>
> Hi Andrey.
>
> Yes it looks indeed familiar. I can do a fair amount of testing and our
> normal production load triggers the problem 6-10 times per day and I'm
> willing to garther data to help move forward. What do you suggest is next?
>
> Jesper
>
>

There is a couple of patches suggested by Vlastimil and others through
discussion, not me neither Christian was able to test them properly
due to kind of environment where bug primarily live (production envs
for both of us). The bare test-env reproducer is a big step forward
indeed. Since then bug was reported a couple of times and workarounded
(by setting ridiculously large amount of memory for vm.min_free), the
larger memory room is (given intensive disk i/o which is able to fill
all memory with certain ratio of active/inactive pages I suppose), the
easier it is to catch the issue.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
