Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 2B3F76B002C
	for <linux-mm@kvack.org>; Thu,  2 Feb 2012 18:01:06 -0500 (EST)
Received: by yhoo22 with SMTP id o22so1800795yho.14
        for <linux-mm@kvack.org>; Thu, 02 Feb 2012 15:01:05 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <4F2AB614.1060907@de.ibm.com>
References: <4F2AB614.1060907@de.ibm.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Thu, 2 Feb 2012 18:00:45 -0500
Message-ID: <CAHGf_=rm286b5FWVRQ8Ob0vakxNcNOHPUksCtnZj4PvOEz47Jg@mail.gmail.com>
Subject: Re: ksm/memory hotplug: lockdep warning for ksm_thread_mutex vs. (memory_chain).rwsem
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gerald.schaefer@de.ibm.com
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Martin Schwidefsky <martin.schwidefsky@de.ibm.com>, Heiko Carstens <h.carstens@de.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@sous-sol.org>, Izik Eidus <izik.eidus@ravellosystems.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

2012/2/2 Gerald Schaefer <gerald.schaefer@de.ibm.com>:
> Setting a memory block offline triggers the following lockdep warning. This
> looks exactly like the issue reported by Kosaki Motohiro in
> https://lkml.org/lkml/2010/10/25/110. Seems like the resulting commit a0b0f58cdd
> did not fix the lockdep warning. I'm able to reproduce it with current 3.3.0-rc2
> as well as 2.6.37-rc4-00147-ga0b0f58.
>
> I'm not familiar with lockdep annotations, but I tried using down_read_nested()
> for (memory_chain).rwsem, similar to the mutex_lock_nested() which was
> introduced for ksm_thread_mutex, but that didn't help.

Heh, interesting. Simple question, do you have any user visible buggy
behavior? or just false positive warn issue?

*_nested() is just hacky trick. so, any change may break their lie.
Anyway I'd like to dig this one. thanks for reporting.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
