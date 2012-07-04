Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id B2F406B0071
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 06:07:19 -0400 (EDT)
Received: by yenr5 with SMTP id r5so7706337yen.14
        for <linux-mm@kvack.org>; Wed, 04 Jul 2012 03:07:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120703134120.dc89c7ae.akpm@linux-foundation.org>
References: <1341035970-20490-1-git-send-email-akinobu.mita@gmail.com>
	<20120703134120.dc89c7ae.akpm@linux-foundation.org>
Date: Wed, 4 Jul 2012 19:07:18 +0900
Message-ID: <CAC5umyhLEp_T1BF6LRNLBMcO-QEE6_hTLL1PAd=65yYRBg3rpQ@mail.gmail.com>
Subject: Re: [PATCH -v5 0/6] notifier error injection
From: Akinobu Mita <akinobu.mita@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, Pavel Machek <pavel@ucw.cz>, "Rafael J. Wysocki" <rjw@sisk.pl>, linux-pm@lists.linux-foundation.org, Greg KH <greg@kroah.com>, linux-mm@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, =?ISO-8859-1?Q?Am=E9rico_Wang?= <xiyou.wangcong@gmail.com>, Michael Ellerman <michael@ellerman.id.au>, Dave Jones <davej@redhat.com>

2012/7/4 Andrew Morton <akpm@linux-foundation.org>:
> On Sat, 30 Jun 2012 14:59:24 +0900
> Akinobu Mita <akinobu.mita@gmail.com> wrote:
>
>> This provides kernel modules that can be used to test the error handling
>> of notifier call chain failures by injecting artifical errors to the
>> following notifier chain callbacks.
>
> No updates to Documentation/fault-injection/?

Thanks for the remainder.
I'll prepare to add a document to it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
