Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 552D16B0071
	for <linux-mm@kvack.org>; Wed, 23 Jun 2010 06:20:07 -0400 (EDT)
Message-ID: <4C21DFBA.2070202@linux.intel.com>
Date: Wed, 23 Jun 2010 12:19:38 +0200
From: Andi Kleen <ak@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH 31/40] trace syscalls: Convert various generic compat
 syscalls
References: <1277287401-28571-1-git-send-email-imunsie@au1.ibm.com> <1277287401-28571-32-git-send-email-imunsie@au1.ibm.com>
In-Reply-To: <1277287401-28571-32-git-send-email-imunsie@au1.ibm.com>
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ian Munsie <imunsie@au1.ibm.com>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, Jason Baron <jbaron@redhat.com>, Frederic Weisbecker <fweisbec@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <michael@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Jeff Moyer <jmoyer@redhat.com>, David Howells <dhowells@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@suse.de>, Dinakar Guniguntala <dino@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Eric Biederman <ebiederm@xmission.com>, Simon Kagstrom <simon.kagstrom@netinsight.net>, WANG Cong <amwang@redhat.com>, Sam Ravnborg <sam@ravnborg.org>, Roland McGrath <roland@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Mike Frysinger <vapier.adi@gmail.com>, Neil Horman <nhorman@tuxdriver.com>, Eric Dumazet <eric.dumazet@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Johannes Berg <johannes@sipsolutions.net>, Roel Kluin <roel.kluin@gmail.com>, linux-fsdevel@vger.kernel.org, kexec@lists.infradead.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

, Ian Munsie wrote:
> From: Ian Munsie<imunsie@au1.ibm.com>
>
> This patch converts numerous trivial compat syscalls through the generic
> kernel code to use the COMPAT_SYSCALL_DEFINE family of macros.

Why? This just makes the code look uglier and the functions harder
to grep for.

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
