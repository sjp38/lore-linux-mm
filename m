Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 0F6456B00CE
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 04:33:11 -0400 (EDT)
Received: by ghrr18 with SMTP id r18so2973379ghr.14
        for <linux-mm@kvack.org>; Mon, 11 Jun 2012 01:33:10 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FD58C54.7050504@kernel.org>
References: <1339325468-30614-1-git-send-email-levinsasha928@gmail.com>
	<1339325468-30614-9-git-send-email-levinsasha928@gmail.com>
	<4FD58C54.7050504@kernel.org>
Date: Mon, 11 Jun 2012 11:33:09 +0300
Message-ID: <CAOJsxLHRfkoS7ZN8bC1MYdiAWFkWV9bVNgc_hOerfUiKmFkyAg@mail.gmail.com>
Subject: Re: [PATCH v3 08/10] mm: frontswap: add tracing support
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Sasha Levin <levinsasha928@gmail.com>, dan.magenheimer@oracle.com, konrad.wilk@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@elte.hu>

On 06/10/2012 07:51 PM, Sasha Levin wrote:
>> Add tracepoints to frontswap API.
>>
>> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>

On Mon, Jun 11, 2012 at 9:12 AM, Minchan Kim <minchan@kernel.org> wrote:
> Normally, adding new tracepoint isn't easy without special reason.
> I'm not sure all of frontswap function tracing would be valuable.
> Shsha, Why do you want to add tracing?
> What's scenario you want to use tracing?

Yup, the added tracepoints look more like function tracing. Shouldn't
you use something like kprobes or ftrace/perf for this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
