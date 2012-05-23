Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 889296B0083
	for <linux-mm@kvack.org>; Wed, 23 May 2012 17:46:17 -0400 (EDT)
Message-ID: <4FBD5A86.70701@redhat.com>
Date: Wed, 23 May 2012 17:45:42 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH RESEND] avoid swapping out with swappiness==0
References: <65795E11DBF1E645A09CEC7EAEE94B9C015A48DF62@USINDEVS02.corp.hds.com>
In-Reply-To: <65795E11DBF1E645A09CEC7EAEE94B9C015A48DF62@USINDEVS02.corp.hds.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Satoru Moriya <satoru.moriya@hds.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Richard Davies <richard.davies@elastichosts.com>, Seiji Aguchi <seiji.aguchi@hds.com>, "dle-develop@lists.sourceforge.net" <dle-develop@lists.sourceforge.net>, Minchan Kim <minchan@kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Christoph Lameter <cl@linux.com>

On 05/23/2012 04:41 PM, Satoru Moriya wrote:

> The patch may not be perfect but, at least, we can improve
> the kernel behavior in the enough filebacked memory case
> with this patch. I believe it's better than nothing.

Agreed.

> Do you have any comments about it?

Only one comment, and it's for Andrew :)

> Signed-off-by: Satoru Moriya<satoru.moriya@hds.com>
> Acked-by: Minchan Kim<minchan@kernel.org>
> Acked-by: Rik van Riel<riel@redhat.com>

Andrew, you can turn my Acked-by into a

Reviewed-by: Rik van Riel<riel@redhat.com>

This is functionality that many people seem to want, and
will not break anything current users typically do.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
