Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx148.postini.com [74.125.245.148])
	by kanga.kvack.org (Postfix) with SMTP id 1D5496B004A
	for <linux-mm@kvack.org>; Tue,  3 Apr 2012 14:17:33 -0400 (EDT)
Received: by lagz14 with SMTP id z14so6651427lag.14
        for <linux-mm@kvack.org>; Tue, 03 Apr 2012 11:17:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <201203310924.19708.arnd@arndb.de>
References: <201203301744.16762.arnd@arndb.de>
	<201203301850.22784.arnd@arndb.de>
	<CAJN=5gDBQJc_KXUadqtzmxPqPF71PDcToGo_T-agNey9eN2MQA@mail.gmail.com>
	<201203310924.19708.arnd@arndb.de>
Date: Tue, 3 Apr 2012 13:17:30 -0500
Message-ID: <CAJN=5gD-_Us6XpZWBWm72c5byytLLYmwW-FeA+a48YxZeWeMtw@mail.gmail.com>
Subject: Re: swap on eMMC and other flash
From: Zach Pfeffer <zach.pfeffer@linaro.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linaro-kernel@lists.linaro.org, linux-mm@kvack.org, Alex Lemberg <alex.lemberg@sandisk.com>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, linux-kernel@vger.kernel.org, Hyojin Jeong <syr.jeong@samsung.com>, "Luca Porzio (lporzio)" <lporzio@micron.com>, kernel-team@android.com, Yejin Moon <yejin.moon@samsung.com>

On 31 March 2012 04:24, Arnd Bergmann <arnd@arndb.de> wrote:
> On Friday 30 March 2012, Zach Pfeffer wrote:
>> Last I read Transparent Huge Pages are still paged in and out a page
>> at a time, is this or was this ever the case? If it is the case should
>> the paging system be extended to support THP which would take care of
>> the big block issues with flash media?
>>
>
> I don't think we ever want to get /that/ big. As I mentioned, going
> beyond 64kb does not improve throughput on most flash media. However,
> paging out 16MB causes a very noticeable delay of up to a few seconds
> on slow drives, which would be inacceptable to users.
>
> Also, that would only deal with the rare case where the data you
> want to page out is actually in huge pages, not the common case.

What I had in mind was being able to swap out big contiguous buffers
used by media and graphics engines in one go. This would allow devices
to support multiple engines without needing to reserve contiguous
memory for each device. They would instead share the contiguous
memory. Only one multimedia engine could run at a time, but that would
be an okay limitation given certain application domains (low end smart
phones).

>
> =A0 =A0 =A0 =A0Arnd



--=20
Zach Pfeffer
Android Platform Team Lead, Linaro Platform Teams
Linaro.org | Open source software for ARM SoCs
Follow Linaro: http://www.facebook.com/pages/Linaro
http://twitter.com/#!/linaroorg - http://www.linaro.org/linaro-blog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
