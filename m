Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx206.postini.com [74.125.245.206])
	by kanga.kvack.org (Postfix) with SMTP id 0A3436B002B
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 18:39:18 -0500 (EST)
Date: Fri, 28 Dec 2012 00:39:13 +0100
From: Zlatko Calusic <zlatko.calusic@iskon.hr>
MIME-Version: 1.0
References: <CA+icZUV_CdAvq1nmOVZeLSAu0mZj+BO0T++REc6U1hevt50hXA@mail.gmail.com>
In-Reply-To: <CA+icZUV_CdAvq1nmOVZeLSAu0mZj+BO0T++REc6U1hevt50hXA@mail.gmail.com>
Message-ID: <50DCDC21.6080303@iskon.hr>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 0000000000000500
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sedat.dilek@gmail.com
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On 28.12.2012 00:30, Sedat Dilek wrote:
> Hi Zlatko,
>
> I am not sure if I hit the same problem as described in this thread.
>
> Under heavy load, while building a customized toolchain for the Freetz
> router project I got a BUG || NULL pointer derefence || kswapd ||
> zone_balanced || pgdat_balanced() etc. (details see my screenshot).
>
> I will try your patch from [1] ***only*** on top of my last
> Linux-v3.8-rc1 GIT setup (post-v3.8-rc1 mainline + some net-fixes).
>

Yes, that's the same bug. It should be fixed with my latest patch, so 
I'd appreciate you testing it, to be on the safe side this time. There 
should be no difference if you apply it to anything newer than 3.8-rc1, 
so go for it. Thanks!

Regards,
-- 
Zlatko

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
