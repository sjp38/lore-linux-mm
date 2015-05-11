Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 06AF96B0038
	for <linux-mm@kvack.org>; Mon, 11 May 2015 11:28:09 -0400 (EDT)
Received: by pdea3 with SMTP id a3so150578411pde.3
        for <linux-mm@kvack.org>; Mon, 11 May 2015 08:28:08 -0700 (PDT)
Received: from mail-pd0-x234.google.com (mail-pd0-x234.google.com. [2607:f8b0:400e:c02::234])
        by mx.google.com with ESMTPS id hu1si18325056pbb.37.2015.05.11.08.28.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 May 2015 08:28:07 -0700 (PDT)
Received: by pdea3 with SMTP id a3so150577535pde.3
        for <linux-mm@kvack.org>; Mon, 11 May 2015 08:28:06 -0700 (PDT)
Date: Tue, 12 May 2015 00:26:47 +0900
From: Namhyung Kim <namhyung@kernel.org>
Subject: Re: [PATCH 4/6] perf kmem: Print gfp flags in human readable string
Message-ID: <20150511152647.GB12220@danjae.kornet>
References: <1429592107-1807-1-git-send-email-namhyung@kernel.org>
 <1429592107-1807-5-git-send-email-namhyung@kernel.org>
 <20150511143536.GP28183@kernel.org>
 <20150511144110.GR28183@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20150511144110.GR28183@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Joonsoo Kim <js1304@gmail.com>, Minchan Kim <minchan@kernel.org>, Pekka Enberg <penberg@kernel.org>, linux-mm@kvack.org

On Mon, May 11, 2015 at 11:41:10AM -0300, Arnaldo Carvalho de Melo wrote:
> Em Mon, May 11, 2015 at 11:35:36AM -0300, Arnaldo Carvalho de Melo escreveu:
> > Em Tue, Apr 21, 2015 at 01:55:05PM +0900, Namhyung Kim escreveu:
> > > Save libtraceevent output and print it in the header.
> > 
> > <SNIP>
> > 
> > > +static int parse_gfp_flags(struct perf_evsel *evsel, struct perf_sample *sample,
> > > +			   unsigned int gfp_flags)
> > > +{
> > > +	char *str, *pos;
> 
> > > +	str = strtok_r(seq.buffer, " ", &pos);
> > 
> > builtin-kmem.c:743:427: error: a??posa?? may be used uninitialized in this
> > function [-Werror=maybe-uninitialized]
> >     new->human_readable = strdup(str + 10);
> >                                                                                                                                                                                                                                                                                                                                                                                                                                            ^
> > builtin-kmem.c:716:14: note: a??posa?? was declared here
> >   char *str, *pos;
> >               ^
> 
> Emphasis on the "may", as according to strtok_r your code is ok, its
> just the compiler that needs to be told that no, it is not being
> accessed uninitialized:
> 
> <quote man strtok>
>        On the first call to strtok_r(), str should point to the string
> to be parsed, and the value of saveptr is ignored.  In subsequent calls,
> str should be NULL, and saveptr should be unchanged since the previous
> call.
> </>
> 
> So just setting it to NULL is enough.

Agreed.

Thanks for fixing this,
Namhyung

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
