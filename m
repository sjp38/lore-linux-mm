Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 6BA2B8D0017
	for <linux-mm@kvack.org>; Sun, 14 Nov 2010 00:21:03 -0500 (EST)
Received: by qwh5 with SMTP id 5so1011362qwh.14
        for <linux-mm@kvack.org>; Sat, 13 Nov 2010 21:21:01 -0800 (PST)
From: Ben Gamari <bgamari.foss@gmail.com>
Subject: Re: fadvise DONTNEED implementation (or lack thereof)
In-Reply-To: <20101114140920.E013.A69D9226@jp.fujitsu.com>
References: <20101109162525.BC87.A69D9226@jp.fujitsu.com> <877hgmr72o.fsf@gmail.com> <20101114140920.E013.A69D9226@jp.fujitsu.com>
Date: Sun, 14 Nov 2010 00:20:57 -0500
Message-ID: <87y68wiipy.fsf@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, rsync@lists.samba.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 14 Nov 2010 14:09:29 +0900 (JST), KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:
> Because we have an alternative solution already. please try memcgroup :)
> 
Alright, fair enough. It still seems like there are many cases where
fadvise seems more appropriate, but memcg should at least satisfy my
personal needs so I'll shut up now. Thanks!

- Ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
