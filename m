Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 4E5828D0001
	for <linux-mm@kvack.org>; Fri, 18 May 2012 04:37:21 -0400 (EDT)
Message-ID: <4FB60A70.6050707@kernel.org>
Date: Fri, 18 May 2012 17:38:08 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH v2 1/3] zsmalloc: support zsmalloc to ARM, MIPS, SUPERH
References: <1337133919-4182-1-git-send-email-minchan@kernel.org>   <1337153329.1751.5.camel@ubuntu.ubuntu-domain>   <4FB44147.5070704@kernel.org>  <1337216199.1837.11.camel@ubuntu.ubuntu-domain>  <4FB4B109.9000703@kernel.org> <1337305553.1844.3.camel@ubuntu.ubuntu-domain>
In-Reply-To: <1337305553.1844.3.camel@ubuntu.ubuntu-domain>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guan Xuetao <gxt@mprc.pku.edu.cn>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nitin Gupta <ngupta@vflare.org>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Russell King <linux@arm.linux.org.uk>, Ralf Baechle <ralf@linux-mips.org>, Paul Mundt <lethal@linux-sh.org>, Chen Liqin <liqin.chen@sunplusct.com>

Hi Guan,

On 05/18/2012 10:45 AM, Guan Xuetao wrote:

> On Thu, 2012-05-17 at 17:04 +0900, Minchan Kim wrote:
> 
>> ...
>> I don't think so.
>> It's terrible experience if all users have to look up local_flush_tlb_kernel_range of arch for using zsmalloc.
>>
>> BTW, does unicore32 support that function?
>> If so, I would like to add unicore32 in Kconfig.
>>
> Yes. Thanks.
> 
> Could you give me some materials on performance and testsuite?


Unfortunately, I don't have them. Nitin, Could you help Guan?

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
