Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2AC359000BD
	for <linux-mm@kvack.org>; Sat, 17 Sep 2011 00:51:44 -0400 (EDT)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id p8H4pctf019885
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 21:51:40 -0700
Received: from qwj8 (qwj8.prod.google.com [10.241.195.72])
	by wpaz21.hot.corp.google.com with ESMTP id p8H4pZBV003784
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 16 Sep 2011 21:51:37 -0700
Received: by qwj8 with SMTP id 8so2496069qwj.5
        for <linux-mm@kvack.org>; Fri, 16 Sep 2011 21:51:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1316231069.27917.28.camel@Joe-Laptop>
References: <1316230753-8693-1-git-send-email-walken@google.com>
	<1316230753-8693-2-git-send-email-walken@google.com>
	<1316231069.27917.28.camel@Joe-Laptop>
Date: Fri, 16 Sep 2011 21:51:34 -0700
Message-ID: <CANN689Em19_T1i6KjeH9JKNZ7ohN6dRz4Yg19+qT0h8ywAVhxQ@mail.gmail.com>
Subject: Re: [PATCH 1/8] page_referenced: replace vm_flags parameter with
 struct pr_info
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Michael Wolf <mjwolf@us.ibm.com>

On Fri, Sep 16, 2011 at 8:44 PM, Joe Perches <joe@perches.com> wrote:
> On Fri, 2011-09-16 at 20:39 -0700, Michel Lespinasse wrote:
>> Introduce struct pr_info, passed into page_referenced() family of functions,
>
> pr_info is a pretty commonly used function/macro.
> Perhaps pageref_info instead?

Hmm, you're right. I can see how people could find this confusing.
I'll make sure to change the name before this gets accepted.

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
