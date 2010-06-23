Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id AA6296B0071
	for <linux-mm@kvack.org>; Wed, 23 Jun 2010 08:42:28 -0400 (EDT)
Date: Wed, 23 Jun 2010 08:41:07 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 31/40] trace syscalls: Convert various generic compat
 syscalls
Message-ID: <20100623124106.GA13200@infradead.org>
References: <1277287401-28571-1-git-send-email-imunsie@au1.ibm.com>
 <1277287401-28571-32-git-send-email-imunsie@au1.ibm.com>
 <4C21DFBA.2070202@linux.intel.com>
 <20100623102931.GB5242@nowhere>
 <4C21E3F8.9000405@linux.intel.com>
 <20100623113806.GD5242@nowhere>
 <4C21FF9A.2040207@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4C21FF9A.2040207@linux.intel.com>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <ak@linux.intel.com>
Cc: Frederic Weisbecker <fweisbec@gmail.com>, Ian Munsie <imunsie@au1.ibm.com>, linux-kernel@vger.kernel.org, linuxppc-dev@ozlabs.org, Jason Baron <jbaron@redhat.com>, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <michael@ellerman.id.au>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Jeff Moyer <jmoyer@redhat.com>, David Howells <dhowells@redhat.com>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "David S. Miller" <davem@davemloft.net>, Greg Kroah-Hartman <gregkh@suse.de>, Dinakar Guniguntala <dino@in.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Eric Biederman <ebiederm@xmission.com>, Simon Kagstrom <simon.kagstrom@netinsight.net>, WANG Cong <amwang@redhat.com>, Sam Ravnborg <sam@ravnborg.org>, Roland McGrath <roland@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Mike Frysinger <vapier.adi@gmail.com>, Neil Horman <nhorman@tuxdriver.com>, Eric Dumazet <eric.dumazet@gmail.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Johannes Berg <johannes@sipsolutions.net>, Roel Kluin <roel.kluin@gmail.com>, linux-fsdevel@vger.kernel.org, kexec@lists.infradead.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, Jun 23, 2010 at 02:35:38PM +0200, Andi Kleen wrote:
> >I haven't heard any complains about existing syscalls wrappers.
> 
> At least for me they always interrupt my grepping.
> 
> >
> >What kind of annotations could solve that?
> 
> If you put the annotation in a separate macro and leave the original
> prototype alone. Then C parsers could still parse it.

I personally hate the way SYSCALL_DEFINE works with passion, mostly
for the grep reason, but also because it looks horribly ugly.

But there is no reason not to be consistent here.  We already use
the wrappers for all native system calls, so leaving the compat
calls out doesn't make any sense.  And I'd cheer for anyone who
comes up with a better scheme for the native and compat wrappers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
