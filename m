Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ve0-f182.google.com (mail-ve0-f182.google.com [209.85.128.182])
	by kanga.kvack.org (Postfix) with ESMTP id 91D626B0037
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 18:43:30 -0500 (EST)
Received: by mail-ve0-f182.google.com with SMTP id jy13so3383936veb.41
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 15:43:30 -0800 (PST)
Received: from mail-ve0-f172.google.com (mail-ve0-f172.google.com [209.85.128.172])
        by mx.google.com with ESMTPS id ks3si18523112vec.127.2013.11.25.15.43.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 25 Nov 2013 15:43:29 -0800 (PST)
Received: by mail-ve0-f172.google.com with SMTP id jw12so3436229veb.17
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 15:43:28 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CALCETrVsZfHqKT-+SHBq7kYx-_3Gvr=mUYUw81uvNuiMxgLWNA@mail.gmail.com>
References: <CALCETrVsZfHqKT-+SHBq7kYx-_3Gvr=mUYUw81uvNuiMxgLWNA@mail.gmail.com>
From: Andy Lutomirski <luto@amacapital.net>
Date: Mon, 25 Nov 2013 15:43:08 -0800
Message-ID: <CALCETrUMS_Rb4Uuw1XEwULzkYYJnaFeLYOYD-7Ao_MjEBABxTw@mail.gmail.com>
Subject: Re: Setting stack NUMA policy?
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Mon, Nov 25, 2013 at 3:35 PM, Andy Lutomirski <luto@amacapital.net> wrote:
> I'm trying to arrange for a process to have a different memory policy
> on its stack as compared to everything else (e.g. mapped libraries).
> Before I start looking for kludges, is there any clean way to do this?
>
> So far, the best I can come up with is to either parse /proc/self/maps
> on startup or to deduce the stack range from the stack pointer and
> then call mbind.  Then, for added fun, I'll need to hook mmap so that
> I can mbind MAP_STACK vmas that are created for threads.
>
> This is awful.  Is there something better?
>
> (What I really want is a separate policy for MAP_SHARED vs MAP_PRIVATE.)

After a bit more thought, I think that what I *really* want is for the
stack for a thread that has affinity for a single NUMA node to
automatically end up on that node.  This seems like a straightforward
win if it's implementable.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
