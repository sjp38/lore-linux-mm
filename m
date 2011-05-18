Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A7E256B0011
	for <linux-mm@kvack.org>; Wed, 18 May 2011 15:59:11 -0400 (EDT)
Received: from mail-ey0-f169.google.com (mail-ey0-f169.google.com [209.85.215.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p4IJwdBK012688
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Wed, 18 May 2011 12:58:40 -0700
Received: by eyd9 with SMTP id 9so846764eyd.14
        for <linux-mm@kvack.org>; Wed, 18 May 2011 12:58:38 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1305682865-27111-1-git-send-email-john.stultz@linaro.org>
References: <1305682865-27111-1-git-send-email-john.stultz@linaro.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 18 May 2011 12:58:17 -0700
Message-ID: <BANLkTikV5EUfpXF1PG3wXLXhou2crm_u2Q@mail.gmail.com>
Subject: Re: [PATCH 0/4] v6 Improve task->comm locking situation
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Stultz <john.stultz@linaro.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Joe Perches <joe@perches.com>, Ingo Molnar <mingo@elte.hu>, Michal Nazarewicz <mina86@mina86.com>, Andy Whitcroft <apw@canonical.com>, Jiri Slaby <jirislaby@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, May 17, 2011 at 6:41 PM, John Stultz <john.stultz@linaro.org> wrote:
>
> While this was brought up at the time, it was not considered
> problematic, as the comm writing was done in such a way that
> only null or incomplete comms could be read. However, recently
> folks have made it clear they want to see this issue resolved.

What folks?

I don't think a new lock (or any lock) is at all appropriate.

There's just no point. Just guarantee that the last byte is always
zero, and you're done.

If you just guarantee that, THERE IS NO RACE. The last byte never
changes. You may get odd half-way strings, but you've trivially
guaranteed that they are C NUL-terminated, with no locking, no memory
ordering, no nothing.

Anybody who asks for any locking is just being a silly git. Tell them
to man the f*ck up.

So I'm not going to apply anything like this for 2.6.39, but I'm also
not going to apply it for 40 or 41 or anything else.

I refuse to accept just stupid unnecessary crap.

                      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
