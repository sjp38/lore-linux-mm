Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id BCADB6B002B
	for <linux-mm@kvack.org>; Mon, 15 Oct 2012 22:56:21 -0400 (EDT)
Received: by mail-ob0-f169.google.com with SMTP id va7so6913501obc.14
        for <linux-mm@kvack.org>; Mon, 15 Oct 2012 19:56:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1350302727-8372-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1350302727-8372-1-git-send-email-kirill.shutemov@linux.intel.com>
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
Date: Mon, 15 Oct 2012 22:56:00 -0400
Message-ID: <CAHGf_=qKcbrFf-GPxinCwWZOj+U4F=-Dh1x5bXc9F3JhekwG8Q@mail.gmail.com>
Subject: Re: [PATCH] mm: use IS_ENABLED(CONFIG_NUMA) instead of NUMA_BUILD
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

On Mon, Oct 15, 2012 at 8:05 AM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
>
> We don't need custom NUMA_BUILD anymore, since we have handy
> IS_ENABLED().
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Looks straightforward.

Acked-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
