Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id 094386B004A
	for <linux-mm@kvack.org>; Sun, 15 Apr 2012 06:38:37 -0400 (EDT)
Received: by lagz14 with SMTP id z14so4316403lag.14
        for <linux-mm@kvack.org>; Sun, 15 Apr 2012 03:38:36 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1334483226.20721.YahooMailNeo@web162003.mail.bf1.yahoo.com>
References: <1334483226.20721.YahooMailNeo@web162003.mail.bf1.yahoo.com>
Date: Sun, 15 Apr 2012 12:38:36 +0200
Message-ID: <CAFLxGvwJCMoiXFn3OgwiX+B50FTzGZmo6eG3xQ1KaPsEVZVA1g@mail.gmail.com>
Subject: Re: [NEW]: Introducing shrink_all_memory from user space
From: richard -rw- weinberger <richard.weinberger@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu_agarwal@yahoo.com>
Cc: "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "pintu.k@samsung.com" <pintu.k@samsung.com>

On Sun, Apr 15, 2012 at 11:47 AM, PINTU KUMAR <pintu_agarwal@yahoo.com> wrote:
> Please provide your valuable feedback and suggestion.

This is fundamentally flawed.
You're assuming that only one program will use this interface.
Linux is a multi/user-tasking system

If we expose it to user space *every* program/user will try too free
memory such that it
can use more.
Can you see the problem?

-- 
Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
