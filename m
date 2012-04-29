Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 60F9F6B0044
	for <linux-mm@kvack.org>; Sun, 29 Apr 2012 15:57:41 -0400 (EDT)
Message-ID: <1335729458.28106.247.camel@gandalf.stny.rr.com>
Subject: Re: [PATCH 01/14] sysctl: provide callback for write into ctl_table
 entry
From: Steven Rostedt <rostedt@goodmis.org>
Date: Sun, 29 Apr 2012 15:57:38 -0400
In-Reply-To: <CA+1xoqfQczszejX8_9hj1ntFS0SpNhErgYSVPL-DxH2WG67JTw@mail.gmail.com>
References: <1335681937-3715-1-git-send-email-levinsasha928@gmail.com>
	 <m1haw33q35.fsf@fess.ebiederm.org>
	 <CA+1xoqfX3hc7FP+8_9sn_mt4_WHkVfqTiPnE79Brs_kAfAFPCQ@mail.gmail.com>
	 <1335708011.28106.245.camel@gandalf.stny.rr.com>
	 <CA+1xoqfQczszejX8_9hj1ntFS0SpNhErgYSVPL-DxH2WG67JTw@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, viro@zeniv.linux.org.uk, fweisbec@gmail.com, mingo@redhat.com, a.p.zijlstra@chello.nl, paulus@samba.org, acme@ghostprotocols.net, james.l.morris@oracle.com, akpm@linux-foundation.org, tglx@linutronix.de, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org

On Sun, 2012-04-29 at 16:14 +0200, Sasha Levin wrote:

> A fix for that could be having the sysctl modifying a different var,
> and having ftrace_enabled from that under a lock, but I'm not sure if
> it's worth the work for the cleanup.

That was my original plan, but it seemed too much of a hassle than it
was worth, as I needed to make sure the mirrored variable was in sync
with ftrace_enabled, otherwise it could be confusing when ftrace was not
working but sysctl showed ftrace set to 1.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
