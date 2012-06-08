Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 5E9DC6B006E
	for <linux-mm@kvack.org>; Thu,  7 Jun 2012 21:12:20 -0400 (EDT)
Date: Thu, 7 Jun 2012 21:12:15 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: a whole bunch of crashes since todays -mm merge.
Message-ID: <20120608011215.GB7191@redhat.com>
References: <20120608002451.GA821@redhat.com>
 <CA+55aFzivM8Z1Bjk3Qo2vtnQhCQ7fQ4rf_a+EXY7noXQcxL_CA@mail.gmail.com>
 <20120608010008.GA7191@redhat.com>
 <CA+55aFxwVWiVwxj39DoJmMTknh7JKvCxzxyu-cMQZwd53jOmgQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFxwVWiVwxj39DoJmMTknh7JKvCxzxyu-cMQZwd53jOmgQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Thu, Jun 07, 2012 at 06:06:27PM -0700, Linus Torvalds wrote:
 > On Thu, Jun 7, 2012 at 6:00 PM, Dave Jones <davej@redhat.com> wrote:
 > >
 > > Or I might just be getting lucky..
 > 
 > Do you have SPLIT_RSS_COUNTING enabled?

I don't think so ? I have CONFIG_SPLIT_PTLOCK_CPUS=999999,
so it looks like that never gets defined unless I'm missing something obvious.
 
 > Do you see multiple "BUG: Bad rss-counter state" messages?

no
 
 > The sync_mm_rss() thing could basically overwrite an already-free'd
 > piece of memory, so it could cause pretty random stuff. But I think
 > you need to be unlucky to hit the window.

the 8169 debug stuff I was trying to run used the function tracer. Could that have
widened the window ?

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
