Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id 711A06B0034
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 15:18:59 -0400 (EDT)
Received: by mail-la0-f43.google.com with SMTP id fs13so648832lab.16
        for <linux-mm@kvack.org>; Wed, 24 Jul 2013 12:18:57 -0700 (PDT)
Date: Wed, 24 Jul 2013 23:18:56 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH] mm: Save soft-dirty bits on swapped pages
Message-ID: <20130724191856.GA27992@moon>
References: <20130724163734.GE24851@moon>
 <CALCETrVWgSMrM2ujpO092ZLQa3pWEQM4vdmHhCVUohUUcoR8AQ@mail.gmail.com>
 <20130724171728.GH8508@moon>
 <1374687373.7382.22.camel@dabdike>
 <CALCETrV5MD1qCQsyz4=t+QW1BJuTBYainewzDfEaXW12S91K=A@mail.gmail.com>
 <20130724181516.GI8508@moon>
 <CALCETrV5NojErxWOc2RpuYKE0g8FfOmKB31oDz46CRu27hmDBA@mail.gmail.com>
 <20130724185256.GA24365@moon>
 <51F0232D.6060306@parallels.com>
 <20130724190453.GJ8508@moon>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130724190453.GJ8508@moon>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Emelyanov <xemul@parallels.com>
Cc: Andy Lutomirski <luto@amacapital.net>, James Bottomley <James.Bottomley@hansenpartnership.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Matt Mackall <mpm@selenic.com>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Marcelo Tosatti <mtosatti@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Stephen Rothwell <sfr@canb.auug.org.au>

On Wed, Jul 24, 2013 at 11:04:53PM +0400, Cyrill Gorcunov wrote:
> On Wed, Jul 24, 2013 at 10:55:41PM +0400, Pavel Emelyanov wrote:
> > > 
> > > Well, some part of information already lays in pte (such as 'file' bit,
> > > swap entries) so it looks natural i think to work on this level. but
> > > letme think if use page struct for that be more convenient...
> > 
> > It hardly will be. Consider we have a page shared between two tasks,
> > then first one "touches" it and soft-dirty is put onto his PTE and,
> > subsequently, the page itself. The we go and clear sofr-dirty for the
> > 2nd task. What should we do with the soft-dirty bit on the page?
> 
> Indeed, this won't help. Well then, bippidy-boppidy-boo, our
> pants are metaphorically on fire (c)

(i meant page flags wont help)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
