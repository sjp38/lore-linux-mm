Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 783F28D0039
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 13:58:00 -0500 (EST)
Received: from mail-iy0-f169.google.com (mail-iy0-f169.google.com [209.85.210.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p1PIvTe3024780
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Fri, 25 Feb 2011 10:57:29 -0800
Received: by iyf13 with SMTP id 13so1568182iyf.14
        for <linux-mm@kvack.org>; Fri, 25 Feb 2011 10:57:29 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20110225175249.GC19059@redhat.com>
References: <20101130200129.GG11905@redhat.com> <compat-not-unlikely@mdm.bga.com>
 <20101201182747.GB6143@redhat.com> <20110225175202.GA19059@redhat.com> <20110225175249.GC19059@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 25 Feb 2011 10:57:09 -0800
Message-ID: <AANLkTinY3QbtZx=2Vo=pCy-b0z_BXK1f1AqXYwNg_Sje@mail.gmail.com>
Subject: Re: [PATCH 2/5] exec: introduce "bool compat" argument
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, pageexec@freemail.hu, Solar Designer <solar@openwall.com>, Eugene Teo <eteo@redhat.com>, Brad Spengler <spender@grsecurity.net>, Roland McGrath <roland@redhat.com>, Milton Miller <miltonm@bga.com>

On Fri, Feb 25, 2011 at 9:52 AM, Oleg Nesterov <oleg@redhat.com> wrote:
> No functional changes, preparation to simplify the review.

I think this is wrong.

If you introduce the "bool compat" thing, you should also change the
type of the argument pointers to some opaque type at the same time.
It's no longer really a

  const char __user *const __user *

pointer at that point. Trying to claim it is, is just wrong. The type
suddently becomes conditional on that 'compat' variable.

                        Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
