Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 66D866B002B
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 08:00:29 -0400 (EDT)
Received: by vcbfl10 with SMTP id fl10so1779921vcb.14
        for <linux-mm@kvack.org>; Fri, 10 Aug 2012 05:00:28 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.LSU.2.00.1208091816240.9631@eggly.anvils>
References: <CAJd=RBAjGaOXfQQ_NX+ax6=tJJ0eg7EXCFHz3rdvSR3j1K3qHA@mail.gmail.com>
	<alpine.LSU.2.00.1208091816240.9631@eggly.anvils>
Date: Fri, 10 Aug 2012 20:00:28 +0800
Message-ID: <CAJd=RBDu5ebAAOuie5yNc8x7vkn7LPfDZZyGzRsCUFNRojWmwQ@mail.gmail.com>
Subject: Re: [patch] mmap: feed back correct prev vma when finding vma
From: Hillf Danton <dhillf@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mikulas Patocka <mpatocka@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

On Fri, Aug 10, 2012 at 9:26 AM, Hugh Dickins <hughd@google.com> wrote:
> On Thu, 9 Aug 2012, Hillf Danton wrote:
>> After walking rb tree, if vma is determined, prev vma has to be determined
>> based on vma; and rb_prev should be considered only if no vma determined.
>
> Why?  Because you think more code is better code?  I disagree.

s/more/correct/

Because feedback is incorrect if we return vma corresponding to
the root node.

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
