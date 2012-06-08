Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id A49F06B0073
	for <linux-mm@kvack.org>; Fri,  8 Jun 2012 03:33:19 -0400 (EDT)
Received: by qcsd16 with SMTP id d16so912428qcs.14
        for <linux-mm@kvack.org>; Fri, 08 Jun 2012 00:33:18 -0700 (PDT)
Message-ID: <4FD1AABD.7010602@gmail.com>
Date: Fri, 08 Jun 2012 03:33:17 -0400
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/5] vmevent: Convert from deferred timer to deferred
 work
References: <20120601122118.GA6128@lizard> <1338553446-22292-2-git-send-email-anton.vorontsov@linaro.org> <4FD170AA.10705@gmail.com> <20120608065828.GA1515@lizard> <84FF21A720B0874AA94B46D76DB98269045F7890@008-AM1MPN1-004.mgdnok.nokia.com> <CAHGf_=rHGotkPYJt65wv+ZDNeO2x+3c5sA8oJmGJX8ehsMHqoA@mail.gmail.com> <84FF21A720B0874AA94B46D76DB98269045F78E1@008-AM1MPN1-004.mgdnok.nokia.com> <CAHGf_=pNJAQP4GhTwtOkBxUDYU4n_-CKmKU7T4PzszwdL9Ju6Q@mail.gmail.com> <84FF21A720B0874AA94B46D76DB98269045F7918@008-AM1MPN1-004.mgdnok.nokia.com>
In-Reply-To: <84FF21A720B0874AA94B46D76DB98269045F7918@008-AM1MPN1-004.mgdnok.nokia.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: leonid.moiseichuk@nokia.com
Cc: kosaki.motohiro@gmail.com, anton.vorontsov@linaro.org, penberg@kernel.org, b.zolnierkie@samsung.com, john.stultz@linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linaro-kernel@lists.linaro.org, patches@linaro.org, kernel-team@android.com

(6/8/12 3:28 AM), leonid.moiseichuk@nokia.com wrote:
>> -----Original Message-----
>> From: ext KOSAKI Motohiro [mailto:kosaki.motohiro@gmail.com]
>> Sent: 08 June, 2012 10:23
> ...
>>> If you wakeup only by signal when memory situation changed you can be
>> not mlocked.
>>> Mlocking uses memory very inefficient way and usually cannot be applied
>> for apps which wants to be notified due to resources restrictions.
>>
>> That's your choice. If you don't need to care cache dropping, We don't
>> enforce it. I only pointed out your explanation was technically incorrect.
>
> My explanation is correct. That is an overhead you have to pay if start to
>use API based on polling from user-space and this overhead narrows API
>applicability.
> Moving all times/tracking to kernel avoid useless wakeups in user-space.

Wrong. CPU don't realized the running code belong to userspace or kernel. Every
code just consume a power. That's why polling timer is wrong from point of power
consumption view.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
