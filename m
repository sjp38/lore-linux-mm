Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7C57C6B0085
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 04:44:43 -0500 (EST)
Received: by iwn10 with SMTP id 10so1138914iwn.14
        for <linux-mm@kvack.org>; Tue, 23 Nov 2010 01:44:42 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1290501502.2390.7029.camel@nimitz>
References: <AANLkTikg-sR97tkG=ST9kjZcHe6puYSvMGh-eA3cnH7X@mail.gmail.com>
	<20101122161158.02699d10.akpm@linux-foundation.org>
	<1290501502.2390.7029.camel@nimitz>
Date: Tue, 23 Nov 2010 10:44:42 +0100
Message-ID: <AANLkTik2Fn-ynUap2fPcRxRdKA=5ZRYG0LJTmqf80y+q@mail.gmail.com>
Subject: Re: Sudden and massive page cache eviction
From: =?UTF-8?Q?Peter_Sch=C3=BCller?= <scode@spotify.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
To: Dave Hansen <dave@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Mattias de Zalenski <zalenski@spotify.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> You don't have anybody messing with /proc/sys/vm/drop_caches, do you?

Highly unlikely given that (1) evictions, while often very
significant, are usually not *complete* (although the first graph
example I provided had a more or less complete eviction) and (2) the
evictions are not obviously periodic indicating some kind of cron job,
and (3) we see the evictions happening across a wide variety of
machines.

So yes, I feel confident that we are not accidentally doing that.

(FWIW though, drop_caches is great. I only recently found out about
it, and it's really useful when benchmarking.)

-- 
/ Peter Schuller aka scode

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
