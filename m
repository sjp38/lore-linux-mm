Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id ABABC6B0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2013 03:07:22 -0400 (EDT)
Received: by mail-lb0-f172.google.com with SMTP id a16so1244187lbj.3
        for <linux-mm@kvack.org>; Thu, 25 Jul 2013 00:07:20 -0700 (PDT)
Date: Thu, 25 Jul 2013 11:07:19 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: Save soft-dirty bits on swapped pages
Message-ID: <20130725070719.GB27992@moon>
References: <CALCETrVWgSMrM2ujpO092ZLQa3pWEQM4vdmHhCVUohUUcoR8AQ@mail.gmail.com>
 <20130724171728.GH8508@moon>
 <1374687373.7382.22.camel@dabdike>
 <CALCETrV5MD1qCQsyz4=t+QW1BJuTBYainewzDfEaXW12S91K=A@mail.gmail.com>
 <20130724181516.GI8508@moon>
 <CALCETrV5NojErxWOc2RpuYKE0g8FfOmKB31oDz46CRu27hmDBA@mail.gmail.com>
 <20130724185256.GA24365@moon>
 <51F0232D.6060306@parallels.com>
 <20130724190453.GJ8508@moon>
 <CALCETrVRQBLrQBL8_Zu0VqBRkDXXr2np57-gt4T59A4jG9jMZw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVRQBLrQBL8_Zu0VqBRkDXXr2np57-gt4T59A4jG9jMZw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Pavel Emelyanov <xemul@parallels.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On Wed, Jul 24, 2013 at 12:40:22PM -0700, Andy Lutomirski wrote:
> 
> Hmm.  So there are at least three kinds of memory:
> 
> Anonymous pages: soft-dirty works
> Shared file-backed pages: soft-dirty does not work
> Private file-backed pages: soft-dirty works (but see below)
> 
> Perhaps another bit should be allocated to expose to userspace either
> "soft-dirty", "soft-clean", or "soft-dirty unsupported"?

> There's another possible issue with private file-backed pages, though:
> how do you distinguish clean-and-not-cowed from cowed-but-soft-clean?
> (The former will reflect changes in the underlying file, I think, but
> the latter won't.)

When fault happens with cow allocation (on write) the pte get soft dirty
bit set (the code uses pte_mkdirty(entry) in __do_fault) and until we
explicitly clean the bit it remains set. Or you mean something else?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
