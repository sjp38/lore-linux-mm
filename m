Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 768418D003B
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 19:52:47 -0400 (EDT)
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id p3PNqd9Y019148
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 16:52:40 -0700
Received: from ewy24 (ewy24.prod.google.com [10.241.103.24])
	by wpaz37.hot.corp.google.com with ESMTP id p3PNqZ4I027299
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 25 Apr 2011 16:52:38 -0700
Received: by ewy24 with SMTP id 24so34368ewy.32
        for <linux-mm@kvack.org>; Mon, 25 Apr 2011 16:52:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1303745985.18763.14.camel@gandalf.stny.rr.com>
References: <1303513209-26436-1-git-send-email-vnagarnaik@google.com>
 <20110425113723.2666.A69D9226@jp.fujitsu.com> <1303745985.18763.14.camel@gandalf.stny.rr.com>
From: Vaibhav Nagarnaik <vnagarnaik@google.com>
Date: Mon, 25 Apr 2011 16:52:05 -0700
Message-ID: <BANLkTimochpX5Tzvj0Yz6Lb+3-tcFuZXqQ@mail.gmail.com>
Subject: Re: [PATCH] trace: Add tracepoints to fs subsystem
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@redhat.com>, Michael Rubin <mrubin@google.com>, David Sharp <dhsharp@google.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Jiaying Zhang <jiayingz@google.com>

On Mon, Apr 25, 2011 at 8:39 AM, Steven Rostedt <rostedt@goodmis.org> wrote:
> On Mon, 2011-04-25 at 11:35 +0900, KOSAKI Motohiro wrote:
>> > From: Jiaying Zhang <jiayingz@google.com>
>> >
>> > Many fs tracepoints can now be traced via ftrace, however there are a
>> > few other tracepoints needed. This patch adds entry and exit tracepoints
>> > for a few additional functions, viz.:
>> > wait_on_buffer
>> > block_write_full_page
>> > mpage_readpages
>> > file_read
>>
>> Zero background description?
>>
>
> Good point.
>
> Could you please describe how this is useful, and how one can benefit
> from these tracepoints.
>
I am sending a new patch with a better description and using the template for
declaring events.

> -- Steve
>
>
>
>

Thanks
Vaibhav Nagarnaik

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
