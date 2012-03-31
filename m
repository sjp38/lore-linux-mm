Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 0B2516B004A
	for <linux-mm@kvack.org>; Sat, 31 Mar 2012 05:24:34 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: swap on eMMC and other flash
Date: Sat, 31 Mar 2012 09:24:19 +0000
References: <201203301744.16762.arnd@arndb.de> <201203301850.22784.arnd@arndb.de> <CAJN=5gDBQJc_KXUadqtzmxPqPF71PDcToGo_T-agNey9eN2MQA@mail.gmail.com>
In-Reply-To: <CAJN=5gDBQJc_KXUadqtzmxPqPF71PDcToGo_T-agNey9eN2MQA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201203310924.19708.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zach Pfeffer <zach.pfeffer@linaro.org>
Cc: linaro-kernel@lists.linaro.org, linux-mm@kvack.org, Alex Lemberg <alex.lemberg@sandisk.com>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, linux-kernel@vger.kernel.org, Hyojin Jeong <syr.jeong@samsung.com>, "Luca Porzio (lporzio)" <lporzio@micron.com>, kernel-team@android.com, Yejin Moon <yejin.moon@samsung.com>

On Friday 30 March 2012, Zach Pfeffer wrote:
> Last I read Transparent Huge Pages are still paged in and out a page
> at a time, is this or was this ever the case? If it is the case should
> the paging system be extended to support THP which would take care of
> the big block issues with flash media?
> 

I don't think we ever want to get /that/ big. As I mentioned, going
beyond 64kb does not improve throughput on most flash media. However,
paging out 16MB causes a very noticeable delay of up to a few seconds
on slow drives, which would be inacceptable to users.

Also, that would only deal with the rare case where the data you
want to page out is actually in huge pages, not the common case.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
