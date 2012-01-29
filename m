Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id CBE976B004D
	for <linux-mm@kvack.org>; Sun, 29 Jan 2012 15:32:12 -0500 (EST)
Received: by obbta7 with SMTP id ta7so4667305obb.14
        for <linux-mm@kvack.org>; Sun, 29 Jan 2012 12:32:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAN_cFWMPNRx75GC0d0Z5CZC0dPH=wv1YVuA+7j4pfFh9ww9bgg@mail.gmail.com>
References: <1327568457-27734-1-git-send-email-m.szyprowski@samsung.com>
	<201201261531.40551.arnd@arndb.de>
	<20120127162624.40cba14e.akpm@linux-foundation.org>
	<CAN_cFWMPNRx75GC0d0Z5CZC0dPH=wv1YVuA+7j4pfFh9ww9bgg@mail.gmail.com>
Date: Sun, 29 Jan 2012 22:32:11 +0200
Message-ID: <CAJL_dMtSArpbKXA3xGdsBH=j0L8m_SnpK=WPX+s5DqdU0OaJhA@mail.gmail.com>
Subject: Re: [PATCHv19 00/15] Contiguous Memory Allocator
From: Anca Emanuel <anca.emanuel@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rob Clark <rob.clark@linaro.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Michal Nazarewicz <mina86@mina86.com>, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daniel Walker <dwalker@codeaurora.org>, Mel Gorman <mel@csn.ul.ie>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Gaignard <benjamin.gaignard@linaro.org>

>> Also there is the supreme tag: "Tested-by:.". =A0Ohad (at least) has bee=
n
>> testing the code. =A0Let's mention that.
>>
>
> fyi Marek, I've been testing CMA as well, both in context of Ohad's
> rpmsg driver and my omapdrm driver (and combination of the two).. =A0so
> you can add:
>
> Tested-by: Rob Clark <rob.clark@linaro.org>
>
> And there are some others from linaro that have written a test driver,
> and various stress test scripts using the test driver. =A0I guess that
> could also count for some additional Tested-by's.

Convince them to report with Tested-by tag.
This is a first step for them to face the open source.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
