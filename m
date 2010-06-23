Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 660266B01AC
	for <linux-mm@kvack.org>; Wed, 23 Jun 2010 06:30:52 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5NAUnhN006214
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Wed, 23 Jun 2010 19:30:50 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id B54EA45DE5A
	for <linux-mm@kvack.org>; Wed, 23 Jun 2010 19:30:49 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B54D45DE54
	for <linux-mm@kvack.org>; Wed, 23 Jun 2010 19:30:49 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 4DC671DB805F
	for <linux-mm@kvack.org>; Wed, 23 Jun 2010 19:30:49 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id DB60E1DB803F
	for <linux-mm@kvack.org>; Wed, 23 Jun 2010 19:30:48 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 31/40] trace syscalls: Convert various generic compat syscalls
In-Reply-To: <4C21DFBA.2070202@linux.intel.com>
References: <1277287401-28571-32-git-send-email-imunsie@au1.ibm.com> <4C21DFBA.2070202@linux.intel.com>
Message-Id: <20100623192930.B5A9.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Wed, 23 Jun 2010 19:30:47 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <ak@linux.intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Ian Munsie <imunsie@au1.ibm.com>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, Jason Baron <jbaron@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <michael@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Jeff Moyer <jmoyer@redhat.com>, David Howells <dhowells@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@suse.de>, Dinakar Guniguntala <dino@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Eric Biederman <ebiederm@xmission.com>, Simon Kagstrom <simon.kagstrom@netinsight.net>, WANG Cong <amwang@redhat.com>, Sam Ravnborg <sam@ravnborg.org>, Roland McGrath <roland@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Mike Frysinger <vapier.adi@gmail.com>, Neil Horman <nhorman@tuxdriver.com>, Eric Dumazet <eric.dumazet@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Johannes Berg <johannes@sipsolutions.net>, Roel Kluin <roel.kluin@gmail.com>, linux-fsdevel@vger.kernel.org, kexec@lists.infradead.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> , Ian Munsie wrote:
> > From: Ian Munsie<imunsie@au1.ibm.com>
> >
> > This patch converts numerous trivial compat syscalls through the generic
> > kernel code to use the COMPAT_SYSCALL_DEFINE family of macros.
> 
> Why? This just makes the code look uglier and the functions harder
> to grep for.

I guess trace-syscall feature need to override COMPAT_SYSCALL_DEFINE. but
It's only guess...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
