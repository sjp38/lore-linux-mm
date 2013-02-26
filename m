Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id F33DF6B0005
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 20:52:44 -0500 (EST)
Received: by mail-oa0-f46.google.com with SMTP id k1so4359557oag.33
        for <linux-mm@kvack.org>; Mon, 25 Feb 2013 17:52:44 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <512B677D.1040501@oracle.com>
References: <512B677D.1040501@oracle.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Mon, 25 Feb 2013 20:52:24 -0500
Message-ID: <CAHGf_=rur29gFs9R9AYeDwnbVBm3b3cOfAn2xyi=mQ+ZbgzEDA@mail.gmail.com>
Subject: Re: mm: BUG in mempolicy's sp_insert
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Dave Jones <davej@redhat.com>, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Mon, Feb 25, 2013 at 8:30 AM, Sasha Levin <sasha.levin@oracle.com> wrote:
> Hi all,
>
> While fuzzing with trinity inside a KVM tools guest running latest -next kernel,
> I've stumbled on the following BUG:
>
> [13551.830090] ------------[ cut here ]------------
> [13551.830090] kernel BUG at mm/mempolicy.c:2187!
> [13551.830090] invalid opcode: 0000 [#1] PREEMPT SMP DEBUG_PAGEALLOC

Unfortunately, I didn't reproduce this. I'll try it tonight.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
