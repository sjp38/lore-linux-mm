Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 6280A6B0044
	for <linux-mm@kvack.org>; Sun, 29 Apr 2012 08:08:20 -0400 (EDT)
Received: by iajr24 with SMTP id r24so4477666iaj.14
        for <linux-mm@kvack.org>; Sun, 29 Apr 2012 05:08:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <m1haw33q35.fsf@fess.ebiederm.org>
References: <1335681937-3715-1-git-send-email-levinsasha928@gmail.com> <m1haw33q35.fsf@fess.ebiederm.org>
From: Sasha Levin <levinsasha928@gmail.com>
Date: Sun, 29 Apr 2012 14:07:58 +0200
Message-ID: <CA+1xoqfX3hc7FP+8_9sn_mt4_WHkVfqTiPnE79Brs_kAfAFPCQ@mail.gmail.com>
Subject: Re: [PATCH 01/14] sysctl: provide callback for write into ctl_table entry
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: viro@zeniv.linux.org.uk, rostedt@goodmis.org, fweisbec@gmail.com, mingo@redhat.com, a.p.zijlstra@chello.nl, paulus@samba.org, acme@ghostprotocols.net, james.l.morris@oracle.com, akpm@linux-foundation.org, tglx@linutronix.de, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-security-module@vger.kernel.org

On Sun, Apr 29, 2012 at 10:22 AM, Eric W. Biederman
<ebiederm@xmission.com> wrote:
> Sasha Levin <levinsasha928@gmail.com> writes:
>
>> Provide a callback that will be called when writing to a ctl_table
>> entry after the user input has been validated.
>>
>> This will simplify user input checks since now it will be possible to
>> remove them out of the proc_handler.
>
> Ick No.
>
> You are simplifying things by taking updates out of locks, and
> introducing races.

Exactly twp of the patches (out of 14) are taking updates out of
locks. I'm quite sure that doing that in the ftrace case is perfectly
fine, and I'll take a second look at the sched-rt one since there
indeed might be a race caused due to the patch that I've missed.

If we figure out that both cases are wrong, the solution would be to
drop these two patches from the series. I have only simplified that
I've thought to be simple common cases, if I'm mistaken about these
two then they're out.

> Your naming of the callback "callback" is much too generic.

I'd name it write_successful_callback() if there was a point for that,
but seeing as there are no other callback types (and I don't see a
need at the moment for other callbacks either), I've just named it
"callback".

Either way, I'm perfectly fine with renaming it to whatever works for
the rest of the community.

> I think the current function call mechanism of sysctl can be improved
> but I don't think you have come up with the right combination of things.

I'm not trying to fix the entire function call mechanism, I'm just
trying to correct a negative pattern that has developed along time.

If it doesn't fit the bigger view of the future of sysctl function
calls, let me know what's that view is exactly and we'll see if this
patch series can work there. If there's something specific that's
bothering you about this series, let me know and I'll fix it. But
saying that it sucks since it doesn't solve all the issues in sysctl
function calls doesn't work for me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
