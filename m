Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id B5BD88D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 15:36:38 -0400 (EDT)
Received: from mail-iy0-f169.google.com (mail-iy0-f169.google.com [209.85.210.169])
	(authenticated bits=0)
	by smtp1.linux-foundation.org (8.14.2/8.13.5/Debian-3ubuntu1.1) with ESMTP id p2EJaFFu014984
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=FAIL)
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 12:36:16 -0700
Received: by iyf13 with SMTP id 13so7357998iyf.14
        for <linux-mm@kvack.org>; Mon, 14 Mar 2011 12:36:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110314190446.GB21845@redhat.com>
References: <20110303100030.B936.A69D9226@jp.fujitsu.com> <20110308134233.GA26884@redhat.com>
 <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com>
 <20110309151946.dea51cde.akpm@linux-foundation.org> <alpine.DEB.2.00.1103111142260.30699@chino.kir.corp.google.com>
 <20110312123413.GA18351@redhat.com> <20110312134341.GA27275@redhat.com>
 <AANLkTinHGSb2_jfkwx=Wjv96phzPCjBROfCTFCKi4Wey@mail.gmail.com>
 <20110313212726.GA24530@redhat.com> <20110314190419.GA21845@redhat.com> <20110314190446.GB21845@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 14 Mar 2011 12:35:52 -0700
Message-ID: <AANLkTi=YnG7tYCSrCPTNSQANOkD2MkP0tMjbOyZbx4NG@mail.gmail.com>
Subject: Re: [PATCH 1/3 for 2.6.38] oom: oom_kill_process: don't set
 TIF_MEMDIE if !p->mm
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrey Vagin <avagin@openvz.org>, David Rientjes <rientjes@google.com>, Frantisek Hrbata <fhrbata@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Mar 14, 2011 at 12:04 PM, Oleg Nesterov <oleg@redhat.com> wrote:
> oom_kill_process() simply sets TIF_MEMDIE and returns if PF_EXITING.
> This is very wrong by many reasons. In particular, this thread can
> be the dead group leader. Check p->mm != NULL.

Explain more, please. Maybe I'm missing some context because I wasn't
cc'd on the original thread, but PF_EXITING gets set by exit_signal(),
and exit_mm() is called almost immediately afterwards which will set
p->mm to NULL.

So afaik, this will basically just remove the whole point of the code
entirely - so why not remove it then?

The combination of testing PF_EXITING and p->mm just doesn't seem to
make any sense.

                      Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
