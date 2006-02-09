Received: by uproxy.gmail.com with SMTP id q2so19763uge
        for <linux-mm@kvack.org>; Wed, 08 Feb 2006 18:57:07 -0800 (PST)
Message-ID: <aec7e5c30602081857t65e58eb7l58299dcde36e6949@mail.gmail.com>
Date: Thu, 9 Feb 2006 11:57:07 +0900
From: Magnus Damm <magnus.damm@gmail.com>
Subject: Re: [RFC] Removing page->flags
In-Reply-To: <43EAA0F4.2060208@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
References: <1139381183.22509.186.camel@localhost>
	 <43EAA0F4.2060208@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Magnus Damm <magnus@valinux.co.jp>, linux-mm@kvack.org, Magnus Damm <damm@opensource.se>
List-ID: <linux-mm.kvack.org>

Hi Kamezawa-san,

On 2/9/06, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Magnus Damm wrote:
> > [RFC] Removing page-flags
> >
> > Moving type A bits:
> >
> > Instead of keeping the bits together, we spread them out and store a
> > pointer to them from pg_data_t.
> >
> This will annoy people who has a job to look into crash-dump's vmcore..like me ;)
> so, I don't like this idea.

Hehe, gotcha. =) I also wonder how well it would work with your zone patches.

> BTW, did you see Nigel's dynamic page-flags idea ?
> I think temporal page-flags can be replaced by some page tracking
> infrastructure.

I'm not familiar with that patch yet, but I will be soon. =) Thanks!

/ magnus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
