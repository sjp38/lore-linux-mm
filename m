Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f48.google.com (mail-ee0-f48.google.com [74.125.83.48])
	by kanga.kvack.org (Postfix) with ESMTP id 55B1F6B0031
	for <linux-mm@kvack.org>; Mon, 10 Mar 2014 11:51:11 -0400 (EDT)
Received: by mail-ee0-f48.google.com with SMTP id e51so3139508eek.21
        for <linux-mm@kvack.org>; Mon, 10 Mar 2014 08:51:10 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id e3si35376047eeo.9.2014.03.10.08.51.08
        for <linux-mm@kvack.org>;
        Mon, 10 Mar 2014 08:51:09 -0700 (PDT)
Date: Mon, 10 Mar 2014 11:50:53 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: deadlock in lru_add_drain ? (3.14rc5)
Message-ID: <20140310155053.GA26188@redhat.com>
References: <20140308220024.GA814@redhat.com>
 <CA+55aFzLxY8Xsn90v1OAsmVBWYPZTiJ74YE=HaCPYR2hvRfk+g@mail.gmail.com>
 <20140310150106.GD25290@htj.dyndns.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140310150106.GD25290@htj.dyndns.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Chris Metcalf <cmetcalf@tilera.com>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Mon, Mar 10, 2014 at 11:01:06AM -0400, Tejun Heo wrote:

 > > On Sat, Mar 8, 2014 at 2:00 PM, Dave Jones <davej@redhat.com> wrote:
 > > > I left my fuzzing box running for the weekend, and checked in on it this evening,
 > > > to find that none of the child processes were making any progress.
 > > > cat'ing /proc/n/stack shows them all stuck in the same place..
 > > > Some examples:
 > 
 > Dave, any chance you can post full sysrq-t dump?

It's too big to fit in the ring-buffer, so some of it gets lost before
it hits syslog, but hopefully what made it to disk is enough.
http://codemonkey.org.uk/junk/sysrq-t

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
