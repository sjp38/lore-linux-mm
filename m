Received: from zps78.corp.google.com (zps78.corp.google.com [172.25.146.78])
	by smtp-out.google.com with ESMTP id m9L2KJ72018399
	for <linux-mm@kvack.org>; Tue, 21 Oct 2008 03:20:19 +0100
Received: from qw-out-2122.google.com (qwe3.prod.google.com [10.241.194.3])
	by zps78.corp.google.com with ESMTP id m9L2KH9W015978
	for <linux-mm@kvack.org>; Mon, 20 Oct 2008 19:20:17 -0700
Received: by qw-out-2122.google.com with SMTP id 3so623907qwe.37
        for <linux-mm@kvack.org>; Mon, 20 Oct 2008 19:20:17 -0700 (PDT)
Message-ID: <6599ad830810201920j4452c304ub34bc77d22afb436@mail.gmail.com>
Date: Mon, 20 Oct 2008 19:20:16 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH -mm 1/5] memcg: replace res_counter
In-Reply-To: <20081021104932.5115a077.kamezawa.hiroyu@jp.fujitsu.com>
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
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, balbir@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Mon, Oct 20, 2008 at 6:49 PM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
> If you give me NACK, maybe I have to try that..
> (But I believe aggregated child-parent counter will be verrrry slow.)

If it's really impossible to implement the aggregated version without
a significant performance hit then that might be a reason to have a
separate counter class. But I'd rather have a clean generic solution
if we can manage it.

> BTW, can we have *unsigned long* version of res_counter ?
> memcg doesn't need *unsigned long long*.

Potentially - but how often is a read-only operation on the
performance sensitive path? Don't most fast-path operations that
involve a res_counter have an update on the res_counter when they
succeed? In which case you have to pull the cache line into a Modified
state anyway.

>
> And as another discussion, I'd like optimize res_counter by per_cpu.

What were you thinking of doing for this?

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
