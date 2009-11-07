Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C34326B004D
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 23:19:34 -0500 (EST)
Received: by pwj4 with SMTP id 4so1186876pwj.6
        for <linux-mm@kvack.org>; Fri, 06 Nov 2009 20:19:33 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.1.10.0911061209520.5187@V090114053VZO-1>
References: <alpine.DEB.1.10.0911051417370.24312@V090114053VZO-1>
	 <alpine.DEB.1.10.0911051419320.24312@V090114053VZO-1>
	 <28c262360911060741x3f7ab0a2k15be645e287e05ac@mail.gmail.com>
	 <alpine.DEB.1.10.0911061209520.5187@V090114053VZO-1>
Date: Sat, 7 Nov 2009 13:19:33 +0900
Message-ID: <28c262360911062019q254f7541lbdc3d94491a69bd6@mail.gmail.com>
Subject: Re: Subject: [RFC MM] mmap_sem scaling: Use mutex and percpu counter
	instead
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: npiggin@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Tejun Heo <tj@kernel.org>, Ingo Molnar <mingo@elte.hu>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

On Sat, Nov 7, 2009 at 2:10 AM, Christoph Lameter
<cl@linux-foundation.org> wrote:
> On Sat, 7 Nov 2009, Minchan Kim wrote:
>
>> How about change from 'mm_readers' to 'is_readers' to improve your
>> goal 'scalibility'?
>
> Good idea. Thanks. Next rev will use your suggestion.
>
> Any creative thoughts on what to do about the 1 millisecond wait period?
>

Hmm,
it would be importatn to prevent livelock for reader to hold lock
continuously before
hodling writer than 1 msec write ovhead.
First of all, After we solve it, second step is that optimize write
overhead, I think.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
