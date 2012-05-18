Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 129D26B0082
	for <linux-mm@kvack.org>; Thu, 17 May 2012 21:47:30 -0400 (EDT)
Message-ID: <1337305553.1844.3.camel@ubuntu.ubuntu-domain>
Subject: Re: [PATCH v2 1/3] zsmalloc: support zsmalloc to ARM, MIPS, SUPERH
From: Guan Xuetao <gxt@mprc.pku.edu.cn>
Date: Fri, 18 May 2012 09:45:53 +0800
In-Reply-To: <4FB4B109.9000703@kernel.org>
References: <1337133919-4182-1-git-send-email-minchan@kernel.org>
	  <1337153329.1751.5.camel@ubuntu.ubuntu-domain>
	  <4FB44147.5070704@kernel.org>
	 <1337216199.1837.11.camel@ubuntu.ubuntu-domain>
	 <4FB4B109.9000703@kernel.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, Paul Mundt <lethal@linux-sh.org>, Chen Liqin <liqin.chen@sunplusct.com>

On Thu, 2012-05-17 at 17:04 +0900, Minchan Kim wrote:

> ...
> I don't think so.
> It's terrible experience if all users have to look up local_flush_tlb_kernel_range of arch for using zsmalloc.
> 
> BTW, does unicore32 support that function?
> If so, I would like to add unicore32 in Kconfig.
> 
Yes. Thanks.

Could you give me some materials on performance and testsuite?


Guan Xuetao

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
