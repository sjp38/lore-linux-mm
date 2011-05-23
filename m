Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 530426B0025
	for <linux-mm@kvack.org>; Mon, 23 May 2011 16:34:44 -0400 (EDT)
Received: from mail-ew0-f41.google.com (mail-ew0-f41.google.com [209.85.215.41])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p4NKYALu013029
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Mon, 23 May 2011 13:34:11 -0700
Received: by ewy9 with SMTP id 9so2847794ewy.14
        for <linux-mm@kvack.org>; Mon, 23 May 2011 13:34:08 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110523192056.GC23629@elte.hu>
References: <BANLkTi=PLuZhx1=rCfOtg=aOTuC1UbuPYg@mail.gmail.com> <20110523192056.GC23629@elte.hu>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 23 May 2011 13:33:48 -0700
Message-ID: <BANLkTikdgM+kSvaEYuQkgCYJZELnvwfetg@mail.gmail.com>
Subject: Re: (Short?) merge window reminder
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-arch@vger.kernel.org, DRI <dri-devel@lists.freedesktop.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Greg KH <gregkh@suse.de>

On Mon, May 23, 2011 at 12:20 PM, Ingo Molnar <mingo@elte.hu> wrote:
>
> I really hope there's also a voice that tells you to wait until .42 before
> cutting 3.0.0! :-)

So I'm toying with 3.0 (and in that case, it really would be "3.0",
not "3.0.0" - the stable team would get the third digit rather than
the fourth one.

But no, it wouldn't be for 42. Despite THHGTTG, I think "40" is a
fairly nice round number.

There's also the timing issue - since we no longer do version numbers
based on features, but based on time, just saying "we're about to
start the third decade" works as well as any other excuse.

But we'll see.

                           Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
