Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E072A8D0039
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 05:39:24 -0500 (EST)
Date: Fri, 21 Jan 2011 10:38:50 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH] ARM: mm: Regarding section when dealing with meminfo
Message-ID: <20110121103850.GI13235@n2100.arm.linux.org.uk>
References: <1295516739-9839-1-git-send-email-pullip.cho@samsung.com> <1295544047.9039.609.camel@nimitz> <20110120180146.GH6335@n2100.arm.linux.org.uk> <AANLkTimsL8YfSdXCBpN2cNVpj8HeJF0f-A7MJQoie+Zm@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <AANLkTimsL8YfSdXCBpN2cNVpj8HeJF0f-A7MJQoie+Zm@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: KyongHo Cho <pullip.cho@samsung.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, Kukjin Kim <kgene.kim@samsung.com>, KeyYoung Park <keyyoung.park@samsung.com>, linux-kernel@vger.kernel.org, Ilho Lee <ilho215.lee@samsung.com>, linux-mm@kvack.org, linux-samsung-soc@vger.kernel.org, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Fri, Jan 21, 2011 at 11:12:27AM +0900, KyongHo Cho wrote:
> Since the size of section is 256 mib and NR_BANKS is defined as 8,
> no ARM system can have more RAM than 2GiB in the current implementation.
> If you want banks in meminfo not to cross sparsemem boundaries,
> we need to find another way of physical memory specification in the kernel.

There is no problem with increasing NR_BANKS.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
