Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id 8141C6B0044
	for <linux-mm@kvack.org>; Wed,  4 Apr 2012 08:21:44 -0400 (EDT)
Message-ID: <4F7C3CE2.5070803@intel.com>
Date: Wed, 04 Apr 2012 15:21:54 +0300
From: Adrian Hunter <adrian.hunter@intel.com>
MIME-Version: 1.0
Subject: Re: swap on eMMC and other flash
References: <201203301744.16762.arnd@arndb.de> <201203301850.22784.arnd@arndb.de>
In-Reply-To: <201203301850.22784.arnd@arndb.de>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: linaro-kernel@lists.linaro.org, linux-mm@kvack.org, "Luca Porzio (lporzio)" <lporzio@micron.com>, Alex Lemberg <alex.lemberg@sandisk.com>, linux-kernel@vger.kernel.org, Saugata Das <saugata.das@linaro.org>, Venkatraman S <venkat@linaro.org>, Yejin Moon <yejin.moon@samsung.com>, Hyojin Jeong <syr.jeong@samsung.com>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, kernel-team@android.com

On 30/03/12 21:50, Arnd Bergmann wrote:
> (sorry for the duplicated email, this corrects the address of the android
> kernel team, please reply here)
> 
> On Friday 30 March 2012, Arnd Bergmann wrote:
> 
>  We've had a discussion in the Linaro storage team (Saugata, Venkat and me,
>  with Luca joining in on the discussion) about swapping to flash based media
>  such as eMMC. This is a summary of what we found and what we think should
>  be done. If people agree that this is a good idea, we can start working
>  on it.

There is mtdswap.

Also the old Nokia N900 had swap to eMMC.

The last I heard was that swap was considered to be simply too slow on hand
held devices.

As systems adopt more RAM, isn't there a decreasing demand for swap?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
