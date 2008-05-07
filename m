Received: from zps76.corp.google.com (zps76.corp.google.com [172.25.146.76])
	by smtp-out.google.com with ESMTP id m477hlDe004797
	for <linux-mm@kvack.org>; Wed, 7 May 2008 08:43:47 +0100
Received: from an-out-0708.google.com (anab33.prod.google.com [10.100.53.33])
	by zps76.corp.google.com with ESMTP id m477hkZp007727
	for <linux-mm@kvack.org>; Wed, 7 May 2008 00:43:46 -0700
Received: by an-out-0708.google.com with SMTP id b33so48215ana.13
        for <linux-mm@kvack.org>; Wed, 07 May 2008 00:43:46 -0700 (PDT)
Message-ID: <6599ad830805070043y4465a32h8e26c5e8890b1100@mail.gmail.com>
Date: Wed, 7 May 2008 00:43:45 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH] mm/cgroup.c add error check
In-Reply-To: <20080507164526.884208f9.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080506195216.4A6D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <6599ad830805062208if98157cwaca4bafa01b8d097@mail.gmail.com>
	 <20080507164526.884208f9.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Li Zefan <lizf@cn.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, May 7, 2008 at 12:45 AM, KAMEZAWA Hiroyuki
<kamezawa.hiroyu@jp.fujitsu.com> wrote:
>  Hmm, but It seems call_usermodehelper()'s fails in silent, no messages.
>  A notify which can be silently dropped is useless.

True, but if we're so short of memory that we can't fork, userspace
probably won't be able to do much about the notification even if it
gets it.

>  Can we add 'printk("notify_on_release: ... is failed")' or some workaround ?
>

Sounds reasonable for debugging, but don't expect any automated
middleware to notice it.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
