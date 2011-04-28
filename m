Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2ED716B0024
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 10:04:56 -0400 (EDT)
Content-Type: text/plain; charset=UTF-8
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback related.
In-reply-to: <1303999282.2081.15.camel@lenovo>
References: <1303920553.2583.7.camel@mulgrave.site> <1303921583-sup-4021@think> <1303923000.2583.8.camel@mulgrave.site> <1303923177-sup-2603@think> <1303924902.2583.13.camel@mulgrave.site> <1303925374-sup-7968@think> <1303926637.2583.17.camel@mulgrave.site> <1303934716.2583.22.camel@mulgrave.site> <1303990590.2081.9.camel@lenovo> <1303993705-sup-5213@think> <1303998140.2081.11.camel@lenovo> <1303998300-sup-4941@think> <1303999282.2081.15.camel@lenovo>
Date: Thu, 28 Apr 2011 10:04:34 -0400
Message-Id: <1303999415-sup-362@think>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Ian King <colin.king@ubuntu.com>
Cc: James Bottomley <james.bottomley@suse.de>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

Excerpts from Colin Ian King's message of 2011-04-28 10:01:22 -0400:
> 
> > Could you post the soft lockups you're seeing?
> 
> As requested, attached

These are not good, but they aren't the lockup James was seeing.  Were
these messages with my patch?  If yes, please post the messages from
without my patch.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
