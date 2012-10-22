Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id D0BC56B0078
	for <linux-mm@kvack.org>; Mon, 22 Oct 2012 16:57:00 -0400 (EDT)
Received: by mail-da0-f41.google.com with SMTP id i14so1670611dad.14
        for <linux-mm@kvack.org>; Mon, 22 Oct 2012 13:57:00 -0700 (PDT)
Date: Mon, 22 Oct 2012 13:56:56 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch for-3.7 v3] mm, mempolicy: hold task->mempolicy refcount
 while reading numa_maps.
In-Reply-To: <5084B3C3.3070906@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1210221356340.30085@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1210152306320.9480@chino.kir.corp.google.com> <alpine.DEB.2.00.1210161657220.14014@chino.kir.corp.google.com> <alpine.DEB.2.00.1210161714110.17278@chino.kir.corp.google.com> <20121017040515.GA13505@redhat.com>
 <alpine.DEB.2.00.1210162222100.26279@chino.kir.corp.google.com> <20121017181413.GA16805@redhat.com> <alpine.DEB.2.00.1210171219010.28214@chino.kir.corp.google.com> <20121017193229.GC16805@redhat.com> <alpine.DEB.2.00.1210171237130.28214@chino.kir.corp.google.com>
 <20121017194501.GA24400@redhat.com> <alpine.DEB.2.00.1210171318400.28214@chino.kir.corp.google.com> <alpine.DEB.2.00.1210171428540.20712@chino.kir.corp.google.com> <507F803A.8000900@jp.fujitsu.com> <507F86BD.7070201@jp.fujitsu.com>
 <alpine.DEB.2.00.1210181255470.26994@chino.kir.corp.google.com> <508110C4.6030805@jp.fujitsu.com> <alpine.DEB.2.00.1210190227240.26815@chino.kir.corp.google.com> <5084B3C3.3070906@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Dave Jones <davej@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, bhutchings@solarflare.com, Konstantin Khlebnikov <khlebnikov@openvz.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Hugh Dickins <hughd@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 22 Oct 2012, Kamezawa Hiroyuki wrote:

> > Looks good, but the patch is whitespace damaged so it doesn't apply.  When
> > that's fixed:
> > 
> > Acked-by: David Rientjes <rientjes@google.com>
> 
> Sorry, I hope this one is not broken...

Looks like Linus picked this up directly, thanks Kame!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
