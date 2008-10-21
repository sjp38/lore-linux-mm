Received: from zps77.corp.google.com (zps77.corp.google.com [172.25.146.77])
	by smtp-out.google.com with ESMTP id m9L6Ubrn007322
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 07:30:38 +0100
Received: from qw-out-1920.google.com (qwk4.prod.google.com [10.241.195.132])
	by zps77.corp.google.com with ESMTP id m9L6UZbD027460
	for <linux-mm@kvack.org>; Mon, 20 Oct 2008 23:30:36 -0700
Received: by qw-out-1920.google.com with SMTP id 4so625963qwk.58
        for <linux-mm@kvack.org>; Mon, 20 Oct 2008 23:30:35 -0700 (PDT)
Message-ID: <6599ad830810202330ra0b2a36r638b8e24d18a60cc@mail.gmail.com>
Date: Mon, 20 Oct 2008 23:30:34 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH -mm 1/5] memcg: replace res_counter
In-Reply-To: <20081021120336.07acb54f.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20081017194804.fce28258.nishimura@mxp.nes.nec.co.jp>
	 <20081017195601.0b9abda1.nishimura@mxp.nes.nec.co.jp>
	 <6599ad830810201253u3bca41d4rabe48eb1ec1d529f@mail.gmail.com>
	 <20081021101430.d2629a81.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830810201829o5483ef48g633e920cce9cc015@mail.gmail.com>
	 <20081021104932.5115a077.kamezawa.hiroyu@jp.fujitsu.com>
	 <6599ad830810201920j4452c304ub34bc77d22afb436@mail.gmail.com>
	 <20081021120336.07acb54f.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, Oct 20, 2008 at 8:03 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> I think we can't do without performance hit. Considering parent<->child counter,
> parent is busier than child if usage is propergated from child to parent. So,
> prefetch will be just a smal help.

You're right, this argument isn't valid in the case of a parent-child counter.

> I don't like *unsigned long long* just because we have to do following
> =
>   res->usage < *some number*
> =
> or
> =
>   val = res->usage.
> =
> always under lock because usage is unsigned long long.

That's true. But isn't the first case going to be accompanied
generally by an increment, for which you'd need to do an atomic
operation anyway? and the second case is most likely for a read from
userspace which isn't on the fast path.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
