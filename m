Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id DC9FD6B006E
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 03:23:22 -0400 (EDT)
Received: by yhr47 with SMTP id 47so1398363yhr.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 00:23:22 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <84FF21A720B0874AA94B46D76DB98269045F78E1@008-AM1MPN1-004.mgdnok.nokia.com>
References: <20120601122118.GA6128@lizard> <1338553446-22292-2-git-send-email-anton.vorontsov@linaro.org>
 <4FD170AA.10705@gmail.com> <20120608065828.GA1515@lizard> <84FF21A720B0874AA94B46D76DB98269045F7890@008-AM1MPN1-004.mgdnok.nokia.com>
 <CAHGf_=rHGotkPYJt65wv+ZDNeO2x+3c5sA8oJmGJX8ehsMHqoA@mail.gmail.com> <84FF21A720B0874AA94B46D76DB98269045F78E1@008-AM1MPN1-004.mgdnok.nokia.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Fri, 8 Jun 2012 03:23:00 -0400
Message-ID: <CAHGf_=pNJAQP4GhTwtOkBxUDYU4n_-CKmKU7T4PzszwdL9Ju6Q@mail.gmail.com>
Subject: Re: [PATCH 2/5] vmevent: Convert from deferred timer to deferred work
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: leonid.moiseichuk@nokia.com
Cc: anton.vorontsov@linaro.org, penberg@kernel.org, b.zolnierkie@samsung.com, john.stultz@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

>> > It also will cause page trashing because user-space code could be pushed
>> out from cache if VM decide.
>>
>> This is completely unrelated issue. Even if notification code is not swapped,
>> userland notify handling code still may be swapped. So, if you must avoid
>> swap, you must use mlock.
>
> If you wakeup only by signal when memory situation changed you can be not mlocked.
> Mlocking uses memory very inefficient way and usually cannot be applied for apps which wants to be notified due to resources restrictions.

That's your choice. If you don't need to care cache dropping, We don't
enforce it. I only pointed out your explanation was technically
incorrect.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
