Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 310B56B006E
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 21:26:07 -0400 (EDT)
Received: by bkcjm19 with SMTP id jm19so1671203bkc.14
        for <linux-mm@kvack.org>; Thu, 07 Jun 2012 18:26:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120608011215.GB7191@redhat.com>
References: <20120608002451.GA821@redhat.com> <CA+55aFzivM8Z1Bjk3Qo2vtnQhCQ7fQ4rf_a+EXY7noXQcxL_CA@mail.gmail.com>
 <20120608010008.GA7191@redhat.com> <CA+55aFxwVWiVwxj39DoJmMTknh7JKvCxzxyu-cMQZwd53jOmgQ@mail.gmail.com>
 <20120608011215.GB7191@redhat.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 7 Jun 2012 18:25:45 -0700
Message-ID: <CA+55aFyxN8vQo7UXwJ0V1jZyE137aX2ZwtXVvGhNFTz4NjxvDg@mail.gmail.com>
Subject: Re: a whole bunch of crashes since todays -mm merge.
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu, Jun 7, 2012 at 6:12 PM, Dave Jones <davej@redhat.com> wrote:
>
> I don't think so ? I have CONFIG_SPLIT_PTLOCK_CPUS=999999,
> so it looks like that never gets defined unless I'm missing something obvious.

Yeah, I think you're right. And in that case I don't think the
sync_mm_rss() patch should matter. Although it does move mm_release()
around, which makes me nervous - that could cause independent issues.
I never got that far in analyzing the patch, because I got hung up on
the obvious problems and decided to revert it as obviously broken and
untested.

Btw, I really wish we didn't do that complicated USE_SPLIT_PTLOCKS ->
SPLIT_RSS_COUNTING stuff hidden in the header files. I suspect we
should do it in the mm/Kconfig file instead, and make them normal
config options. I think that makes it easier to grep for.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
