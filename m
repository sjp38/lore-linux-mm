Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 7EBEE6B0062
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 16:52:56 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so7460844pbb.14
        for <linux-mm@kvack.org>; Mon, 11 Jun 2012 13:52:55 -0700 (PDT)
Date: Mon, 11 Jun 2012 13:52:54 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: fix protection column misplacing in /proc/zoneinfo
In-Reply-To: <CAHGf_=rbss0RsoFn7NZ7oFCpCZuEYkPDXaHSW4KHg=Vu8703xA@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1206111350550.6389@chino.kir.corp.google.com>
References: <1339422650-9798-1-git-send-email-kosaki.motohiro@gmail.com> <alpine.DEB.2.00.1206110856180.31180@router.home> <4FD60127.1000805@jp.fujitsu.com> <alpine.DEB.2.00.1206111336370.4552@chino.kir.corp.google.com>
 <CAHGf_=rbss0RsoFn7NZ7oFCpCZuEYkPDXaHSW4KHg=Vu8703xA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: cl@linux.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 11 Jun 2012, KOSAKI Motohiro wrote:

> > We do, and I think it would be a shame to break anything parsing the way
> > that this file has been written for the past several years for something
> > as aesthetical as this.
> 
> How do you parsing?
> 
> Several years, some one added ZVC stat. therefore, hardcoded line
> number parsing never work anyway. And in the other hand, if you are
> parsing, field
> name, my patch doesn't break anything.
> 

Yeah, your patch doesn't break me because I'm parsing by field name but I 
feel it would be a shame for it to break anyone else that may not be doing 
it that way.  The set of users in the world who are parsing /proc/zoneinfo 
who may or may not do crazy things is not fully represented on this 
thread, so I don't feel it's worth it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
