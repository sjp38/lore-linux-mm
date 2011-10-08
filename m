Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id EC4036B002C
	for <linux-mm@kvack.org>; Sat,  8 Oct 2011 03:23:38 -0400 (EDT)
Received: by wwi36 with SMTP id 36so5607564wwi.26
        for <linux-mm@kvack.org>; Sat, 08 Oct 2011 00:23:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1110071958200.13992@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1110071954040.13992@chino.kir.corp.google.com> <alpine.DEB.2.00.1110071958200.13992@chino.kir.corp.google.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Sat, 8 Oct 2011 03:23:15 -0400
Message-ID: <CAHGf_=rQN35sM6SLLz9NrgSooKhmsVhR2msEY3jxnLSj+SAcXQ@mail.gmail.com>
Subject: Re: [patch v2] oom: thaw threads if oom killed thread is frozen
 before deferring
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

2011/10/7 David Rientjes <rientjes@google.com>:
> If a thread has been oom killed and is frozen, thaw it before returning
> to the page allocator. =A0Otherwise, it can stay frozen indefinitely and
> no memory will be freed.
>
> Reported-by: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: David Rientjes <rientjes@google.com>
> ---
> =A0v2: adds the missing header file include, the resend patch was based o=
n a
> =A0 =A0 previous patch from Michal that is no longer needed if this is
> =A0 =A0 applied.

Looks ok to me.
Michal, do you agree this patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
