Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id A982C6B010D
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 06:38:01 -0400 (EDT)
Received: by obbwd18 with SMTP id wd18so8695934obb.14
        for <linux-mm@kvack.org>; Mon, 11 Jun 2012 03:38:00 -0700 (PDT)
Message-ID: <1339411150.4999.43.camel@lappy>
Subject: Re: [PATCH v3 08/10] mm: frontswap: add tracing support
From: Sasha Levin <levinsasha928@gmail.com>
Date: Mon, 11 Jun 2012 12:39:10 +0200
In-Reply-To: <CAOJsxLHRfkoS7ZN8bC1MYdiAWFkWV9bVNgc_hOerfUiKmFkyAg@mail.gmail.com>
References: <1339325468-30614-1-git-send-email-levinsasha928@gmail.com>
	 <1339325468-30614-9-git-send-email-levinsasha928@gmail.com>
	 <4FD58C54.7050504@kernel.org>
	 <CAOJsxLHRfkoS7ZN8bC1MYdiAWFkWV9bVNgc_hOerfUiKmFkyAg@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, dan.magenheimer@oracle.com, konrad.wilk@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@elte.hu>

On Mon, 2012-06-11 at 11:33 +0300, Pekka Enberg wrote:
> On 06/10/2012 07:51 PM, Sasha Levin wrote:
> >> Add tracepoints to frontswap API.
> >>
> >> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> 
> On Mon, Jun 11, 2012 at 9:12 AM, Minchan Kim <minchan@kernel.org> wrote:
> > Normally, adding new tracepoint isn't easy without special reason.
> > I'm not sure all of frontswap function tracing would be valuable.
> > Shsha, Why do you want to add tracing?
> > What's scenario you want to use tracing?

I added tracing when working on code to integrate KVM with
frontswap/cleancache and needed to see that the flow of code between
host side kvm and zcache and guest side cleancache, frontswap and kvm is
correct.

> Yup, the added tracepoints look more like function tracing. Shouldn't
> you use something like kprobes or ftrace/perf for this?

I'm not sure really, there are quite a few options provided by the
kernel...

I used tracepoints because I was working on code that integrates with
KVM, and saw that KVM was working with tracepoints in a very similar way
to what I needed, so I assumed tracepoints is the right choice for me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
