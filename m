Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D994A900001
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 11:57:55 -0400 (EDT)
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback
 related.
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <1303928753.2417.6.camel@lenovo>
References: <1303920553.2583.7.camel@mulgrave.site>
	 <1303921583-sup-4021@think> <1303923000.2583.8.camel@mulgrave.site>
	 <1303923177-sup-2603@think> <1303924902.2583.13.camel@mulgrave.site>
	 <1303925374-sup-7968@think>  <1303926637.2583.17.camel@mulgrave.site>
	 <1303928753.2417.6.camel@lenovo>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 28 Apr 2011 10:57:42 -0500
Message-ID: <1304006262.2598.2.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Ian King <colin.king@ubuntu.com>
Cc: Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Wed, 2011-04-27 at 19:25 +0100, Colin Ian King wrote:
> Just like to add that I've seen almost identical issues with 2.6.38
> copying large amounts of data to an ext4 filesystem with systems with
> small amounts of memory.
> 
> I found that increasing /sys/fs/ext4/sdaX/max_writeback_mb_bump worked
> around the issue.

With the PREEMPT kernel, values of 256 and 512 don't prevent kswapd
spinning up to 99% and staying there.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
