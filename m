Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 5524B6B006C
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 09:02:12 -0400 (EDT)
Received: by igbqf9 with SMTP id qf9so10346369igb.1
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 06:02:12 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.136])
        by mx.google.com with ESMTP id w8si6463902igp.35.2015.04.07.06.02.10
        for <linux-mm@kvack.org>;
        Tue, 07 Apr 2015 06:02:10 -0700 (PDT)
Date: Tue, 7 Apr 2015 10:02:08 -0300
From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [PATCH 9/9] tools lib traceevent: Honor operator priority
Message-ID: <20150407130208.GH11983@kernel.org>
References: <1428298576-9785-1-git-send-email-namhyung@kernel.org>
 <1428298576-9785-10-git-send-email-namhyung@kernel.org>
 <20150406104504.41e398d3@gandalf.local.home>
 <20150407075226.GE23913@sejong>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150407075226.GE23913@sejong>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Namhyung Kim <namhyung@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org

Em Tue, Apr 07, 2015 at 04:52:26PM +0900, Namhyung Kim escreveu:
> On Mon, Apr 06, 2015 at 10:45:04AM -0400, Steven Rostedt wrote:
> > >  		type = process_arg_token(event, right, tok, type);
> > > -		arg->op.right = right;
> > > +
> > > +		if (right->type == PRINT_OP &&
> > > +		    get_op_prio(arg->op.op) < get_op_prio(right->op.op)) {
> > > +			struct print_arg tmp;
> > > +
> > > +			/* swap ops according to the priority */

> > This isn't really a swap. Better term to use is "rotate".

> You're right!

> > But other than that,

> > Acked-by: Steven Rostedt <rostedt@goodmis.org>
> 
> Thanks for the review

Ok, so just doing that s/swap/rotate/g, sticking Rostedt's ack and
applying, ok?

- Arnaldo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
