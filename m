Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 073346B0073
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 10:11:45 -0400 (EDT)
Received: by patj18 with SMTP id j18so80089300pat.2
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 07:11:44 -0700 (PDT)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id s14si11602849pdj.57.2015.04.07.07.11.44
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Apr 2015 07:11:44 -0700 (PDT)
Received: by paboj16 with SMTP id oj16so80216822pab.0
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 07:11:44 -0700 (PDT)
Date: Tue, 7 Apr 2015 23:10:42 +0900
From: Namhyung Kim <namhyung@kernel.org>
Subject: Re: [PATCH 9/9] tools lib traceevent: Honor operator priority
Message-ID: <20150407141042.GF15878@danjae.kornet>
References: <1428298576-9785-1-git-send-email-namhyung@kernel.org>
 <1428298576-9785-10-git-send-email-namhyung@kernel.org>
 <20150406104504.41e398d3@gandalf.local.home>
 <20150407075226.GE23913@sejong>
 <20150407130208.GH11983@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20150407130208.GH11983@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org

On Tue, Apr 07, 2015 at 10:02:08AM -0300, Arnaldo Carvalho de Melo wrote:
> Em Tue, Apr 07, 2015 at 04:52:26PM +0900, Namhyung Kim escreveu:
> > On Mon, Apr 06, 2015 at 10:45:04AM -0400, Steven Rostedt wrote:
> > > >  		type = process_arg_token(event, right, tok, type);
> > > > -		arg->op.right = right;
> > > > +
> > > > +		if (right->type == PRINT_OP &&
> > > > +		    get_op_prio(arg->op.op) < get_op_prio(right->op.op)) {
> > > > +			struct print_arg tmp;
> > > > +
> > > > +			/* swap ops according to the priority */
> 
> > > This isn't really a swap. Better term to use is "rotate".
> 
> > You're right!
> 
> > > But other than that,
> 
> > > Acked-by: Steven Rostedt <rostedt@goodmis.org>
> > 
> > Thanks for the review
> 
> Ok, so just doing that s/swap/rotate/g, sticking Rostedt's ack and
> applying, ok?

Sure thing!

Thanks for your work,
Namhyung

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
