Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yh0-f51.google.com (mail-yh0-f51.google.com [209.85.213.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5A1066B0035
	for <linux-mm@kvack.org>; Fri, 29 Nov 2013 11:50:59 -0500 (EST)
Received: by mail-yh0-f51.google.com with SMTP id c41so5364325yho.38
        for <linux-mm@kvack.org>; Fri, 29 Nov 2013 08:50:59 -0800 (PST)
Received: from comal.ext.ti.com (comal.ext.ti.com. [198.47.26.152])
        by mx.google.com with ESMTPS id v3si3086573yhd.163.2013.11.29.08.50.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 29 Nov 2013 08:50:58 -0800 (PST)
Message-ID: <5298C5C2.60008@ti.com>
Date: Fri, 29 Nov 2013 11:50:10 -0500
From: Santosh Shilimkar <santosh.shilimkar@ti.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/24] mm: Use memblock interface instead of bootmem
References: <1383954120-24368-1-git-send-email-santosh.shilimkar@ti.com>
In-Reply-To: <1383954120-24368-1-git-send-email-santosh.shilimkar@ti.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: tj@kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Santosh Shilimkar <santosh.shilimkar@ti.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Yinghai Lu <yinghai@kernel.org>, "H.
 Peter Anvin" <hpa@zytor.com>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Nicolas Pitre <nicolas.pitre@linaro.org>, Olof Johansson <olof@lixom.net>

Tejun, Andrew,

On Friday 08 November 2013 06:41 PM, Santosh Shilimkar wrote:
> Tejun and others,
> 
> Following up with the earlier RFC [1] comments, here is the updated
> patch series based on the discussion. This series is the last bottleneck
> now for me to enable the coherency on keystone ARM LPAE architecture on which
> the physical memory starts after 4BG. I would like to get these patches
> in next merge window(3.14), so any help in terms of testing/comments is
> appreciated.
> 
Now since the 3.13-rc1 is out, it will be best to apply these patches 
on memblock tree so that they start appearing in next to catch any
regressions, issues etc. It will give us some time to fix any issues
arises from next.

For convenience, I have re-based the series on top of 3.13-rc1 and
pushed it on below tree.

git://git.kernel.org/pub/scm/linux/kernel/git/ssantosh/linux-keystone.git
for_3.14/memblock

web-url:
https://git.kernel.org/cgit/linux/kernel/git/ssantosh/linux-keystone.git/log/?h=for_3.14/memblock

Can you please pull these in you tree and apply against your
next branch ?

Regards,
Santosh		 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
