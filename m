Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 481B06B0023
	for <linux-mm@kvack.org>; Thu, 28 Apr 2011 09:45:51 -0400 (EDT)
Content-Type: text/plain; charset=UTF-8
From: Chris Mason <chris.mason@oracle.com>
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback related.
In-reply-to: <1303998140.2081.11.camel@lenovo>
References: <1303920553.2583.7.camel@mulgrave.site> <1303921583-sup-4021@think> <1303923000.2583.8.camel@mulgrave.site> <1303923177-sup-2603@think> <1303924902.2583.13.camel@mulgrave.site> <1303925374-sup-7968@think> <1303926637.2583.17.camel@mulgrave.site> <1303934716.2583.22.camel@mulgrave.site> <1303990590.2081.9.camel@lenovo> <1303993705-sup-5213@think> <1303998140.2081.11.camel@lenovo>
Date: Thu, 28 Apr 2011 09:45:34 -0400
Message-Id: <1303998300-sup-4941@think>
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Colin Ian King <colin.king@ubuntu.com>
Cc: James Bottomley <james.bottomley@suse.de>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

Excerpts from Colin Ian King's message of 2011-04-28 09:42:20 -0400:
> 
> On Thu, 2011-04-28 at 08:29 -0400, Chris Mason wrote:
> > Excerpts from Colin Ian King's message of 2011-04-28 07:36:30 -0400:
> > > One more data point to add, I've been looking at an identical issue when
> > > copying large amounts of data.  I bisected this - and the lockups occur
> > > with commit 
> > > 3e7d344970673c5334cf7b5bb27c8c0942b06126 - before that I don't see the
> > > issue. With this commit, my file copy test locks up after ~8-10
> > > iterations, before this commit I can copy > 100 times and don't see the
> > > lockup.
> > 
> > Well, that's really interesting.  I tried with compaction on here and
> > couldn't trigger it, but this (very very lightly) tested patch might
> > help.
> > 
> Thanks Chris,
> 
> I've given this a soak test but I still see the same lockup.

Could you post the soft lockups you're seeing?

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
