Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5E6C08D0017
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 00:09:33 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAE59Vxb020385
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 14 Nov 2010 14:09:31 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0BE3B45DE4F
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:09:31 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D7AE345DE4D
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:09:30 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C1C291DB8038
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:09:30 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7E4DC1DB8037
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 14:09:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: fadvise DONTNEED implementation (or lack thereof)
In-Reply-To: <877hgmr72o.fsf@gmail.com>
References: <20101109162525.BC87.A69D9226@jp.fujitsu.com> <877hgmr72o.fsf@gmail.com>
Message-Id: <20101114140920.E013.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun, 14 Nov 2010 14:09:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Ben Gamari <bgamari.foss@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-kernel@vger.kernel.org, rsync@lists.samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> On Tue,  9 Nov 2010 16:28:02 +0900 (JST), KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> > So, I don't think application developers will use fadvise() aggressively
> > because we don't have a cross platform agreement of a fadvice behavior.
> > 
> I strongly disagree. For a long time I have been trying to resolve
> interactivity issues caused by my rsync-based backup script. Many kernel
> developers have said that there is nothing the kernel can do without
> more information from user-space (e.g. cgroups, madvise). While cgroups
> help, the fix is round-about at best and requires configuration where
> really none should be necessary. The easiest solution for everyone
> involved would be for rsync to use FADV_DONTNEED. The behavior doesn't
> need to be perfectly consistent between platforms for the flag to be
> useful so long as each implementation does something sane to help
> use-once access patterns.
> 
> People seem to mention frequently that there are no users of
> FADV_DONTNEED and therefore we don't need to implement it. It seems like
> this is ignoring an obvious catch-22. Currently rsync has no fadvise
> support at all, since using[1] the implemented hints to get the desired
> effect is far too complicated^M^M^M^Mhacky to be considered
> merge-worthy. Considering the number of Google hits returned for
> fadvise, I wouldn't be surprised if there were countless other projects
> with this same difficulty. We want to be able to tell the kernel about
> our useage patterns, but the kernel won't listen.

Because we have an alternative solution already. please try memcgroup :)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
