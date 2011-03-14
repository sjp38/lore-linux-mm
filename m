Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 19FA28D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 15:13:12 -0400 (EDT)
Date: Mon, 14 Mar 2011 20:04:19 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 0/3 for 2.6.38] oom: fixes
Message-ID: <20110314190419.GA21845@redhat.com>
References: <alpine.DEB.2.00.1103011108400.28110@chino.kir.corp.google.com> <20110303100030.B936.A69D9226@jp.fujitsu.com> <20110308134233.GA26884@redhat.com> <alpine.DEB.2.00.1103081549530.27910@chino.kir.corp.google.com> <20110309151946.dea51cde.akpm@linux-foundation.org> <alpine.DEB.2.00.1103111142260.30699@chino.kir.corp.google.com> <20110312123413.GA18351@redhat.com> <20110312134341.GA27275@redhat.com> <AANLkTinHGSb2_jfkwx=Wjv96phzPCjBROfCTFCKi4Wey@mail.gmail.com> <20110313212726.GA24530@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110313212726.GA24530@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrey Vagin <avagin@openvz.org>, David Rientjes <rientjes@google.com>, Frantisek Hrbata <fhrbata@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 03/13, Oleg Nesterov wrote:
>
> The _trivial_ exploit (distinct from this one) can kill the system.
> ...
> I'll return to this tomorrow.

I am going to give up, I do not understand the changes in -mm ;)

But I think we have other problems which should be fixed first.
Note that each fix has the "this is _not_ enough" comment. I was
going to _try_ to do something more complete later, but since we
are going to add more hacks^W subtle changes... lets fix the obvious
bugs first.

Add Linus. Hopefully the changes are simple enough. But once again,
we need more.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
