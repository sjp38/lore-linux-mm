Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 5CC556B00EB
	for <linux-mm@kvack.org>; Tue, 22 May 2012 21:47:08 -0400 (EDT)
Message-ID: <4FBC41A2.1080402@kernel.org>
Date: Wed, 23 May 2012 10:47:14 +0900
From: Minchan Kim <minchan@kernel.org>
MIME-Version: 1.0
Subject: Re: [PATCH] zsmalloc: use unsigned long instead of void *
References: <1337567013-4741-1-git-send-email-minchan@kernel.org> <4FBA4EE2.8050308@linux.vnet.ibm.com> <4FBC2916.5000305@kernel.org>
In-Reply-To: <4FBC2916.5000305@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
Cc: Seth Jennings <sjenning@linux.vnet.ibm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Dan Magenheimer <dan.magenheimer@oracle.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Nitin Gupta <ngupta@vflare.org>

On 05/23/2012 09:02 AM, Minchan Kim wrote:

> Maybe I will resend next spin based on v3.4 today
> I hope it doesn't hurt you.


I didn't based v2 patches on v3.4 because mainline tree doesn't have lots of staging patchset.
So it's not a good idea to apply staging patchset in mainline. I believe linux-next is good candidate
for it so I sent v2 patches against next-20120522.

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
