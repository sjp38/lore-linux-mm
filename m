Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 3B01F6B0081
	for <linux-mm@kvack.org>; Mon, 16 Jul 2012 13:57:15 -0400 (EDT)
Received: by yhr47 with SMTP id 47so6588631yhr.14
        for <linux-mm@kvack.org>; Mon, 16 Jul 2012 10:57:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <874np7r4ee.fsf@erwin.mina86.com>
References: <1342455272-32703-1-git-send-email-js1304@gmail.com>
	<874np7r4ee.fsf@erwin.mina86.com>
Date: Tue, 17 Jul 2012 02:57:14 +0900
Message-ID: <CAAmzW4OS7=xfm0shxsi0k8kJ=2oNs4MQAEJ=EJv_xRydrukF1w@mail.gmail.com>
Subject: Re: [PATCH 1/3] mm: correct return value of migrate_pages()
From: JoonSoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@tlen.pl>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>

2012/7/17 Michal Nazarewicz <mina86@tlen.pl>:
> Acked-by: Michal Nazarewicz <mina86@mina86.com>

Thanks.

> Actually, it makes me wonder if there is any code that uses this
> information.  If not, it would be best in my opinion to make it return
> zero or negative error code, but that would have to be checked.

I think that, too.
I looked at every callsites for migrate_pages() and there is no place
which really need fail count.
This function sometimes makes caller error-prone,
so I think changing return value is preferable.

How do you think, Christoph?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
