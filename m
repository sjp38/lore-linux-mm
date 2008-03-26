Received: from zps37.corp.google.com (zps37.corp.google.com [172.25.146.37])
	by smtp-out.google.com with ESMTP id m2QFM1Lp024240
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 15:22:02 GMT
Received: from py-out-1112.google.com (pygz59.prod.google.com [10.34.227.59])
	by zps37.corp.google.com with ESMTP id m2QFLxrs005140
	for <linux-mm@kvack.org>; Wed, 26 Mar 2008 08:22:00 -0700
Received: by py-out-1112.google.com with SMTP id z59so3871719pyg.27
        for <linux-mm@kvack.org>; Wed, 26 Mar 2008 08:21:59 -0700 (PDT)
Message-ID: <6599ad830803260821r5c5b56f3pd381659d0866c87b@mail.gmail.com>
Date: Wed, 26 Mar 2008 08:21:59 -0700
From: "Paul Menage" <menage@google.com>
Subject: Re: [RFC][-mm] Memory controller add mm->owner
In-Reply-To: <47EA3684.60107@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080324140142.28786.97267.sendpatchset@localhost.localdomain>
	 <6599ad830803240803s5160101bi2bf68b36085f777f@mail.gmail.com>
	 <47E7D51E.4050304@linux.vnet.ibm.com>
	 <6599ad830803240934g2a70d904m1ca5548f8644c906@mail.gmail.com>
	 <47E7E5D0.9020904@linux.vnet.ibm.com>
	 <6599ad830803241046l61e2965t52fd28e165d5df7a@mail.gmail.com>
	 <47E8E4F3.6090604@linux.vnet.ibm.com>
	 <47EA2592.7090600@linux.vnet.ibm.com>
	 <6599ad830803260420v236127cfydd8cf828fcce65bb@mail.gmail.com>
	 <47EA3684.60107@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Wed, Mar 26, 2008 at 4:41 AM, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>
>  Hmmm.. the 99.9% of the time is just guess work (not measured, could be possibly
>  true). I see and understand your code below. But before I try and implement
>  something like that, I was wondering why zap_threads() does not have that
>  heuristic. That should explain my inhibition.
>
>  Can anyone elaborate on zap_threads further?
>

zap_threads() has to find *all* the other users, whereas in this case
we only have to find one other user.

Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
