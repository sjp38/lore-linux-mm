Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 5FBFF8D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 21:33:08 -0400 (EDT)
Received: from kpbe12.cbf.corp.google.com (kpbe12.cbf.corp.google.com [172.25.105.76])
	by smtp-out.google.com with ESMTP id p2U1X0Tp027679
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 18:33:00 -0700
Received: from qwi4 (qwi4.prod.google.com [10.241.195.4])
	by kpbe12.cbf.corp.google.com with ESMTP id p2U1WHJc025760
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 18:32:58 -0700
Received: by qwi4 with SMTP id 4so629786qwi.15
        for <linux-mm@kvack.org>; Tue, 29 Mar 2011 18:32:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110330102205.E925.A69D9226@jp.fujitsu.com>
References: <1301419696-2045-1-git-send-email-yinghan@google.com>
	<20110330102205.E925.A69D9226@jp.fujitsu.com>
Date: Tue, 29 Mar 2011 18:32:58 -0700
Message-ID: <BANLkTinDON4dV9ipZYJsxBW-bENMajw-wA@mail.gmail.com>
Subject: Re: [PATCH] Stack trace dedup
From: Ying Han <yinghan@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

On Tue, Mar 29, 2011 at 6:21 PM, KOSAKI Motohiro
<kosaki.motohiro@jp.fujitsu.com> wrote:
>> This doesn't build.
>> ---
>> =A0arch/x86/Kconfig =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 =A03 +
>> =A0arch/x86/include/asm/stacktrace.h | =A0 =A02 +-
>> =A0arch/x86/kernel/dumpstack.c =A0 =A0 =A0 | =A0 =A05 +-
>> =A0arch/x86/kernel/dumpstack_64.c =A0 =A0| =A0 10 +++-
>> =A0arch/x86/kernel/stacktrace.c =A0 =A0 =A0| =A0108 ++++++++++++++++++++=
+++++++++++++++++
>> =A0include/linux/sched.h =A0 =A0 =A0 =A0 =A0 =A0 | =A0 10 +++-
>> =A0init/main.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 | =A0 =A01 +
>> =A0kernel/sched.c =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0| =A0 25 ++++++=
++-
>> =A08 files changed, 154 insertions(+), 10 deletions(-)
>
> This is slightly reticence changelog. Can you please explain a purpose
> and benefit?

Hi:

Sorry about the spam. This is a patch that I was preparing to send
upstream but not ready yet. I don't know why it got sent out ( must be
myself did something wrong on my keyboard ) .

In a short, this eliminate the duplication of task stack trace in dump
messages. The problem w/ fixed size of dmesg ring buffer limits how
many task trace to be logged. When the duplication remains high, we
lose important information. This patch reduces the duplication by
dumping the first task stack trace only for contiguous duplications.

I will prepare it later with full commit description.

Thanks

--Ying


>
>
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
