Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f181.google.com (mail-ie0-f181.google.com [209.85.223.181])
	by kanga.kvack.org (Postfix) with ESMTP id B64C66B006E
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 09:57:10 -0400 (EDT)
Received: by iebmp1 with SMTP id mp1so47020358ieb.0
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 06:57:10 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0221.hostedemail.com. [216.40.44.221])
        by mx.google.com with ESMTP id 84si6568613ioi.91.2015.04.07.06.57.10
        for <linux-mm@kvack.org>;
        Tue, 07 Apr 2015 06:57:10 -0700 (PDT)
Date: Tue, 7 Apr 2015 09:57:04 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 9/9] tools lib traceevent: Honor operator priority
Message-ID: <20150407095704.7021b15e@gandalf.local.home>
In-Reply-To: <20150407130208.GH11983@kernel.org>
References: <1428298576-9785-1-git-send-email-namhyung@kernel.org>
	<1428298576-9785-10-git-send-email-namhyung@kernel.org>
	<20150406104504.41e398d3@gandalf.local.home>
	<20150407075226.GE23913@sejong>
	<20150407130208.GH11983@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Namhyung Kim <namhyung@kernel.org>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jiri Olsa <jolsa@redhat.com>, LKML <linux-kernel@vger.kernel.org>, David Ahern <dsahern@gmail.com>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <js1304@gmail.com>, linux-mm@kvack.org

On Tue, 7 Apr 2015 10:02:08 -0300
Arnaldo Carvalho de Melo <acme@kernel.org> wrote:

> Ok, so just doing that s/swap/rotate/g, sticking Rostedt's ack and
> applying, ok?

I'm fine with that.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
