Message-ID: <43EAA0F4.2060208@jp.fujitsu.com>
Date: Thu, 09 Feb 2006 10:55:00 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [RFC] Removing page->flags
References: <1139381183.22509.186.camel@localhost>
In-Reply-To: <1139381183.22509.186.camel@localhost>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Magnus Damm <magnus@valinux.co.jp>
Cc: linux-mm@kvack.org, Magnus Damm <damm@opensource.se>
List-ID: <linux-mm.kvack.org>

Magnus Damm wrote:
> [RFC] Removing page-flags
> 
> Moving type A bits:
> 
> Instead of keeping the bits together, we spread them out and store a
> pointer to them from pg_data_t.
> 
This will annoy people who has a job to look into crash-dump's vmcore..like me ;)
so, I don't like this idea.

BTW, did you see Nigel's dynamic page-flags idea ?
I think temporal page-flags can be replaced by some page tracking
infrastructure.

-- Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
