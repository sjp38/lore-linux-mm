Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id D8DAF6B0062
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 16:37:53 -0400 (EDT)
Received: by dakp5 with SMTP id p5so7250811dak.14
        for <linux-mm@kvack.org>; Mon, 11 Jun 2012 13:37:53 -0700 (PDT)
Date: Mon, 11 Jun 2012 13:37:51 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm: fix protection column misplacing in /proc/zoneinfo
In-Reply-To: <4FD60127.1000805@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1206111336370.4552@chino.kir.corp.google.com>
References: <1339422650-9798-1-git-send-email-kosaki.motohiro@gmail.com> <alpine.DEB.2.00.1206110856180.31180@router.home> <4FD60127.1000805@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: cl@linux.com, kosaki.motohiro@gmail.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 11 Jun 2012, KOSAKI Motohiro wrote:

> > You are not worried about breaking something that may scan the zoneinfo
> > output with this change? Its been this way for 6 years and its likely that
> > tools expect the current layout.
> 
> I don't worry about this. Because of, /proc/zoneinfo is cray machine unfrinedly
> format and afaik no application uses it.
> 

We do, and I think it would be a shame to break anything parsing the way 
that this file has been written for the past several years for something 
as aesthetical as this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
