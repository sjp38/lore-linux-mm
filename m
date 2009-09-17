Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B28896B009C
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 19:34:42 -0400 (EDT)
Received: from zps35.corp.google.com (zps35.corp.google.com [172.25.146.35])
	by smtp-out.google.com with ESMTP id n8HNYef8007981
	for <linux-mm@kvack.org>; Fri, 18 Sep 2009 00:34:40 +0100
Received: from pxi38 (pxi38.prod.google.com [10.243.27.38])
	by zps35.corp.google.com with ESMTP id n8HNYK6E011514
	for <linux-mm@kvack.org>; Thu, 17 Sep 2009 16:34:37 -0700
Received: by pxi38 with SMTP id 38so384779pxi.29
        for <linux-mm@kvack.org>; Thu, 17 Sep 2009 16:34:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20090915184237.13160e2a.akpm@linux-foundation.org>
References: <6599ad830909151740n2affe0daw27618ccae9c737d6@mail.gmail.com>
	 <20090915184237.13160e2a.akpm@linux-foundation.org>
Date: Thu, 17 Sep 2009 16:34:37 -0700
Message-ID: <6599ad830909171634j64038843k8570b5200db5f2e7@mail.gmail.com>
Subject: Re: 2.6.32 -mm merge plans (cgroups)
From: Paul Menage <menage@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Sep 15, 2009 at 6:42 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
>
> What would happen if we merged it as-is? =A0Can we be confident that the
> resulting bugs won't impact others

Yes, I'm fairly confident that the race/bug wouldn't affect anyone who
didn't write to a cgroup.procs file.

> and that we can get them all fixed
> up reasonably promptly?

No, that's not clear yet.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
