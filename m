Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 7F6346B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 10:16:03 -0400 (EDT)
Received: by wixw10 with SMTP id w10so41150158wix.0
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 07:16:03 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id nf9si3952629wic.28.2015.03.18.07.16.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 18 Mar 2015 07:16:02 -0700 (PDT)
Message-ID: <5509889C.2080602@suse.cz>
Date: Wed, 18 Mar 2015 15:15:56 +0100
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: High system load and 3TB of memory.
References: <52ec58f434865829c37337624d124981.squirrel@shrek.krogh.cc> <CABYiri81_RAtJizfpOdNPc6m9_Q2u0O35NX0ZhO1cxFpm866HQ@mail.gmail.com> <a0dcd8d7307e313474d4d721c76bb5a9.squirrel@shrek.krogh.cc> <CABYiri9BcgNEYD5C4qGf=3q6a=d549Rp9rXD7BAo8NkVDAPOqA@mail.gmail.com>
In-Reply-To: <CABYiri9BcgNEYD5C4qGf=3q6a=d549Rp9rXD7BAo8NkVDAPOqA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Korolyov <andrey@xdel.ru>, jesper@krogh.cc
Cc: linux-mm@kvack.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Christian Marie <christian@ponies.io>

On 03/14/2015 06:33 PM, Andrey Korolyov wrote:
> On Sat, Mar 14, 2015 at 8:25 PM,  <jesper@krogh.cc> wrote:
>>> On Sat, Mar 14, 2015 at 8:05 PM,  <jesper@krogh.cc> wrote:
>>>> Hi
>>>> I have a 3.13 (ubuntu LTS) server with 3TB of memory and under certain
>>>> load
>>>> conditions it can spiral off to 80+% system load. Per recommendation on
>>>> IRC
>>>> yesterday I have captured 2 perf reports (I'm new to perf, so I'm not
>>>> sure they tell precisely whats needed.
>>>>
>>>> Bad situation (high sysload 80%+)
>>
>>
>>> Hi Jesper, please take a look on
>>> http://marc.info/?l=linux-mm&m=141605213522925&w=2, there is a long
>>> and unfinished discussion as it seems very problematic to make a
>>> deterministic reproduction of the bug in our environments. If you can
>>> observe same lockups with more ease, it`ll help a lot in the issue
>>> pinning and fixing.
>>
>>
>> Hi Andrey.
>>
>> Yes it looks indeed familiar. I can do a fair amount of testing and our
>> normal production load triggers the problem 6-10 times per day and I'm
>> willing to garther data to help move forward. What do you suggest is next?
>>
>> Jesper
>>
>>
>
> There is a couple of patches suggested by Vlastimil and others through
> discussion, not me neither Christian was able to test them properly
> due to kind of environment where bug primarily live (production envs
> for both of us). The bare test-env reproducer is a big step forward
> indeed. Since then bug was reported a couple of times and workarounded
> (by setting ridiculously large amount of memory for vm.min_free), the
> larger memory room is (given intensive disk i/o which is able to fill
> all memory with certain ratio of active/inactive pages I suppose), the
> easier it is to catch the issue.

Right, it would be great if you could try it with 3.18+ kernel and 
possibly Joonsoo's patch from
http://marc.info/?l=linux-mm&m=141774145601066


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
