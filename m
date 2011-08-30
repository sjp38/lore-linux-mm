Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id B7061900137
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 14:06:09 -0400 (EDT)
Received: from wpaz33.hot.corp.google.com (wpaz33.hot.corp.google.com [172.24.198.97])
	by smtp-out.google.com with ESMTP id p7UI66Ia025233
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 11:06:06 -0700
Received: from qwc23 (qwc23.prod.google.com [10.241.193.151])
	by wpaz33.hot.corp.google.com with ESMTP id p7UI5eXY027541
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 11:06:04 -0700
Received: by qwc23 with SMTP id 23so3825188qwc.3
        for <linux-mm@kvack.org>; Tue, 30 Aug 2011 11:06:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20110829163425.GF5672@quack.suse.cz>
References: <1314038327-22645-1-git-send-email-curtw@google.com>
	<1314038327-22645-2-git-send-email-curtw@google.com>
	<20110829162313.GE5672@quack.suse.cz>
	<20110829163425.GF5672@quack.suse.cz>
Date: Tue, 30 Aug 2011 11:06:02 -0700
Message-ID: <CAO81RMaQbJJiC=M8ckU8c7jF_MPSCrzsqNTP3Oa3er9CdqRx9Q@mail.gmail.com>
Subject: Re: [PATCH 2/3 v3] writeback: Add a 'reason' to wb_writeback_work
From: Curt Wohlgemuth <curtw@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Christoph Hellwig <hch@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Michael Rubin <mrubin@google.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Mon, Aug 29, 2011 at 9:34 AM, Jan Kara <jack@suse.cz> wrote:
> On Mon 29-08-11 18:23:13, Jan Kara wrote:
>> On Mon 22-08-11 11:38:46, Curt Wohlgemuth wrote:
>> > This creates a new 'reason' field in a wb_writeback_work
>> > structure, which unambiguously identifies who initiates
>> > writeback activity. =A0A 'wb_reason' enumeration has been
>> > added to writeback.h, to enumerate the possible reasons.
>> >
>> > The 'writeback_work_class' and tracepoint event class and
>> > 'writeback_queue_io' tracepoints are updated to include the
>> > symbolic 'reason' in all trace events.
>> >
>> > And the 'writeback_inodes_sbXXX' family of routines has had
>> > a wb_stats parameter added to them, so callers can specify
>> > why writeback is being started.
>> =A0 Looks good. You can add: Acked-by: Jan Kara <jack@suse.cz>
> =A0Oh, one small typo correction:
>
>> > +#define show_work_reason(reason) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
>> > + =A0 __print_symbolic(reason, =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
>> > + =A0 =A0 =A0 =A0 =A0 {WB_REASON_BALANCE_DIRTY, =A0 =A0 =A0 "balance_d=
irty"}, =A0 =A0 =A0 \
>> > + =A0 =A0 =A0 =A0 =A0 {WB_REASON_BACKGROUND, =A0 =A0 =A0 =A0 =A0"backg=
round"}, =A0 =A0 =A0 =A0 =A0\
>> > + =A0 =A0 =A0 =A0 =A0 {WB_REASON_TRY_TO_FREE_PAGES, =A0 "try_to_free_p=
ages"}, =A0 \
>> > + =A0 =A0 =A0 =A0 =A0 {WB_REASON_SYNC, =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
"sync"}, =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
>> > + =A0 =A0 =A0 =A0 =A0 {WB_REASON_PERIODIC, =A0 =A0 =A0 =A0 =A0 =A0"per=
iodic"}, =A0 =A0 =A0 =A0 =A0 =A0\
>> > + =A0 =A0 =A0 =A0 =A0 {WB_REASON_LAPTOP_TIMER, =A0 =A0 =A0 =A0"laptop_=
timer"}, =A0 =A0 =A0 =A0\
>> > + =A0 =A0 =A0 =A0 =A0 {WB_REASON_FREE_MORE_MEM, =A0 =A0 =A0 "free_more=
_memory"}, =A0 =A0\
>> > + =A0 =A0 =A0 =A0 =A0 {WB_REASON_FS_FREE_SPACE, =A0 =A0 =A0 "FS_free_s=
pace"}, =A0 =A0 =A0 \
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 ^^ should be in
> non-capital letters?

Oops, right, thanks for catching this.

Curt

>> > + =A0 =A0 =A0 =A0 =A0 {WB_REASON_FORKER_THREAD, =A0 =A0 =A0 "forker_th=
read"} =A0 =A0 =A0 =A0\
>> > + =A0 )
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Honza
> --
> Jan Kara <jack@suse.cz>
> SUSE Labs, CR
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
