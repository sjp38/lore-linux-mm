Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 6387D6B0062
	for <linux-mm@kvack.org>; Mon, 11 Jun 2012 17:05:01 -0400 (EDT)
Date: Mon, 11 Jun 2012 16:04:58 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: fix protection column misplacing in /proc/zoneinfo
In-Reply-To: <CAHGf_=rbss0RsoFn7NZ7oFCpCZuEYkPDXaHSW4KHg=Vu8703xA@mail.gmail.com>
Message-ID: <alpine.DEB.2.00.1206111602540.9391@router.home>
References: <1339422650-9798-1-git-send-email-kosaki.motohiro@gmail.com> <alpine.DEB.2.00.1206110856180.31180@router.home> <4FD60127.1000805@jp.fujitsu.com> <alpine.DEB.2.00.1206111336370.4552@chino.kir.corp.google.com>
 <CAHGf_=rbss0RsoFn7NZ7oFCpCZuEYkPDXaHSW4KHg=Vu8703xA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: David Rientjes <rientjes@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 11 Jun 2012, KOSAKI Motohiro wrote:

> Several years, some one added ZVC stat. therefore, hardcoded line

You are talking to the "some one".... The aim at that point was not the
beauty of the output but the scaling of the counter operations. There was
no intention in placing things a certain way. I'd be fine with changes as
long as we are sure that they do not break anything.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
