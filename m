Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx139.postini.com [74.125.245.139])
	by kanga.kvack.org (Postfix) with SMTP id 6D1126B0044
	for <linux-mm@kvack.org>; Sun, 29 Apr 2012 10:14:37 -0400 (EDT)
Received: by iajr24 with SMTP id r24so4599431iaj.14
        for <linux-mm@kvack.org>; Sun, 29 Apr 2012 07:14:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1335708011.28106.245.camel@gandalf.stny.rr.com>
References: <1335681937-3715-1-git-send-email-levinsasha928@gmail.com>
 <m1haw33q35.fsf@fess.ebiederm.org> <CA+1xoqfX3hc7FP+8_9sn_mt4_WHkVfqTiPnE79Brs_kAfAFPCQ@mail.gmail.com>
 <1335708011.28106.245.camel@gandalf.stny.rr.com>
From: Sasha Levin <levinsasha928@gmail.com>
Date: Sun, 29 Apr 2012 16:14:16 +0200
Message-ID: <CA+1xoqfQczszejX8_9hj1ntFS0SpNhErgYSVPL-DxH2WG67JTw@mail.gmail.com>
Subject: Re: [PATCH 01/14] sysctl: provide callback for write into ctl_table entry
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, viro@zeniv.linux.org.uk, fweisbec@gmail.com, mingo@redhat.com, a.p.zijlstra@chello.nl, paulus@samba.org, acme@ghostprotocols.net, james.l.morris@oracle.com, akpm@linux-foundation.org, tglx@linutronix.de, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org

On Sun, Apr 29, 2012 at 4:00 PM, Steven Rostedt <rostedt@goodmis.org> wrote:
> On Sun, 2012-04-29 at 14:07 +0200, Sasha Levin wrote:
>> On Sun, Apr 29, 2012 at 10:22 AM, Eric W. Biederman
>
>> Exactly twp of the patches (out of 14) are taking updates out of
>> locks. I'm quite sure that doing that in the ftrace case is perfectly
>> fine, and I'll take a second look at the sched-rt one since there
>> indeed might be a race caused due to the patch that I've missed.
>
> The update of ftrace_enable must be done under the ftrace_lock mutex.
> With the exception of ftrace_kill() which is a one shot deal that kills
> ftrace updates until a reboot.

Understood.

A fix for that could be having the sysctl modifying a different var,
and having ftrace_enabled from that under a lock, but I'm not sure if
it's worth the work for the cleanup.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
