Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx125.postini.com [74.125.245.125])
	by kanga.kvack.org (Postfix) with SMTP id 72BD26B002B
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 18:42:57 -0500 (EST)
Received: by mail-qc0-f180.google.com with SMTP id v28so5155672qcm.39
        for <linux-mm@kvack.org>; Thu, 27 Dec 2012 15:42:56 -0800 (PST)
MIME-Version: 1.0
Reply-To: sedat.dilek@gmail.com
In-Reply-To: <50DCDC21.6080303@iskon.hr>
References: <CA+icZUV_CdAvq1nmOVZeLSAu0mZj+BO0T++REc6U1hevt50hXA@mail.gmail.com>
	<50DCDC21.6080303@iskon.hr>
Date: Fri, 28 Dec 2012 00:42:56 +0100
Message-ID: <CA+icZUX2g0R46QNFpntA1r6E3wu0HNhBjk+Kjm581aUBgM6VKA@mail.gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 0000000000000500
From: Sedat Dilek <sedat.dilek@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zlatko Calusic <zlatko.calusic@iskon.hr>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Fri, Dec 28, 2012 at 12:39 AM, Zlatko Calusic
<zlatko.calusic@iskon.hr> wrote:
> On 28.12.2012 00:30, Sedat Dilek wrote:
>>
>> Hi Zlatko,
>>
>> I am not sure if I hit the same problem as described in this thread.
>>
>> Under heavy load, while building a customized toolchain for the Freetz
>> router project I got a BUG || NULL pointer derefence || kswapd ||
>> zone_balanced || pgdat_balanced() etc. (details see my screenshot).
>>
>> I will try your patch from [1] ***only*** on top of my last
>> Linux-v3.8-rc1 GIT setup (post-v3.8-rc1 mainline + some net-fixes).
>>
>
> Yes, that's the same bug. It should be fixed with my latest patch, so I'd
> appreciate you testing it, to be on the safe side this time. There should be
> no difference if you apply it to anything newer than 3.8-rc1, so go for it.
> Thanks!
>

Not sure how I can really reproduce this bug as one build worked fine
within my last v3.8-rc1 kernel.
I increased the parallel-make-jobs-number from "4" to "8" to stress a
bit harder.
Just building right now... and will report.

If you have any test-case (script or whatever), please let me/us know.

Thanks.

- Sedat -

> Regards,
> --
> Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
