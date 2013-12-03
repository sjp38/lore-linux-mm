Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 820ED6B0037
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 19:32:37 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id r10so19103218pdi.24
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 16:32:37 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id j9si4781626pav.281.2013.12.02.16.32.35
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 16:32:36 -0800 (PST)
Date: Mon, 2 Dec 2013 16:32:34 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/24] mm: Use memblock interface instead of bootmem
Message-Id: <20131202163234.3edcb8e77834322314c435ea@linux-foundation.org>
In-Reply-To: <5298C5C2.60008@ti.com>
References: <1383954120-24368-1-git-send-email-santosh.shilimkar@ti.com>
	<5298C5C2.60008@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Santosh Shilimkar <santosh.shilimkar@ti.com>
Cc: tj@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Russell King <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, Nicolas Pitre <nicolas.pitre@linaro.org>, Olof Johansson <olof@lixom.net>

On Fri, 29 Nov 2013 11:50:10 -0500 Santosh Shilimkar <santosh.shilimkar@ti.com> wrote:

> Tejun, Andrew,
> 
> On Friday 08 November 2013 06:41 PM, Santosh Shilimkar wrote:
> > Tejun and others,
> > 
> > Following up with the earlier RFC [1] comments, here is the updated
> > patch series based on the discussion. This series is the last bottleneck
> > now for me to enable the coherency on keystone ARM LPAE architecture on which
> > the physical memory starts after 4BG. I would like to get these patches
> > in next merge window(3.14), so any help in terms of testing/comments is
> > appreciated.
> > 
> Now since the 3.13-rc1 is out, it will be best to apply these patches 
> on memblock tree so that they start appearing in next to catch any
> regressions, issues etc. It will give us some time to fix any issues
> arises from next.
> 
> For convenience, I have re-based the series on top of 3.13-rc1 and
> pushed it on below tree.
> 
> git://git.kernel.org/pub/scm/linux/kernel/git/ssantosh/linux-keystone.git
> for_3.14/memblock
> 
> web-url:
> https://git.kernel.org/cgit/linux/kernel/git/ssantosh/linux-keystone.git/log/?h=for_3.14/memblock
> 
> Can you please pull these in you tree and apply against your
> next branch ?

It would cause me much joy if yinghai were able to find time to review
all this.  The patches are a bit old now, so perhaps a resend will help.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
