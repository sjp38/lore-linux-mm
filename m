Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 57BD68D0039
	for <linux-mm@kvack.org>; Tue,  1 Feb 2011 01:00:48 -0500 (EST)
Received: from mail-iy0-f169.google.com (mail-iy0-f169.google.com [209.85.210.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p1160CrV014267
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Mon, 31 Jan 2011 22:00:13 -0800
Received: by iyj17 with SMTP id 17so5930953iyj.14
        for <linux-mm@kvack.org>; Mon, 31 Jan 2011 22:00:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110201010341.GA21676@google.com>
References: <20110201010341.GA21676@google.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 1 Feb 2011 15:59:52 +1000
Message-ID: <AANLkTinG7eHR1_kfEyvJYw52ngyvqv5UzigEOddsi9ye@mail.gmail.com>
Subject: Re: [PATCH] mlock: operate on any regions with protection != PROT_NONE
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Michel Lespinasse <walken@google.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Tao Ma <tm@tao.ma>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>
List-ID: <linux-mm.kvack.org>

On Tue, Feb 1, 2011 at 11:03 AM, Michel Lespinasse <walken@google.com> wrote:
>
> I am proposing to let mlock ignore vma protection in all cases except
> PROT_NONE.

What's so special about PROT_NONE? If you want to mlock something
without actually being able to then fault that in, why not?

IOW, why wouldn't it be right to just make FOLL_FORCE be unconditional in mlock?

             Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
