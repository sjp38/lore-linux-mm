Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 88DCD6B006E
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 21:06:49 -0400 (EDT)
Received: by bkcjm19 with SMTP id jm19so1655268bkc.14
        for <linux-mm@kvack.org>; Thu, 07 Jun 2012 18:06:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120608010008.GA7191@redhat.com>
References: <20120608002451.GA821@redhat.com> <CA+55aFzivM8Z1Bjk3Qo2vtnQhCQ7fQ4rf_a+EXY7noXQcxL_CA@mail.gmail.com>
 <20120608010008.GA7191@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 7 Jun 2012 18:06:27 -0700
Message-ID: <CA+55aFxwVWiVwxj39DoJmMTknh7JKvCxzxyu-cMQZwd53jOmgQ@mail.gmail.com>
Subject: Re: a whole bunch of crashes since todays -mm merge.
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu, Jun 7, 2012 at 6:00 PM, Dave Jones <davej@redhat.com> wrote:
>
> Or I might just be getting lucky..

Do you have SPLIT_RSS_COUNTING enabled?

Do you see multiple "BUG: Bad rss-counter state" messages?

The sync_mm_rss() thing could basically overwrite an already-free'd
piece of memory, so it could cause pretty random stuff. But I think
you need to be unlucky to hit the window.

                Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
