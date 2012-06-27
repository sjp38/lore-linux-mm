Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id C52856B0069
	for <linux-mm@kvack.org>; Wed, 27 Jun 2012 15:26:13 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so2426111pbb.14
        for <linux-mm@kvack.org>; Wed, 27 Jun 2012 12:26:13 -0700 (PDT)
Date: Wed, 27 Jun 2012 12:26:08 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: Early boot panic on machine with lots of memory
Message-ID: <20120627192608.GQ15811@google.com>
References: <20120619212618.GK32733@google.com>
 <CAE9FiQVECyRBie-kgBETmqxPaMx24kUt1W07qAqoGD4vNus5xQ@mail.gmail.com>
 <20120621201728.GB4642@google.com>
 <CAE9FiQXubmnKHjnqOxVeoJknJZFNuStCcW=1XC6jLE7eznkTmg@mail.gmail.com>
 <20120622185113.GK4642@google.com>
 <CAE9FiQVV+WOWywnanrP7nX-wai=aXmQS1Dcvt4PxJg5XWynC+Q@mail.gmail.com>
 <20120622192919.GL4642@google.com>
 <CAE9FiQVeJYwpgHjAFp5Q7PazOjeDvN_etrnej987Rc94TjXfAg@mail.gmail.com>
 <20120627181330.GN15811@google.com>
 <CAE9FiQXk4abAzuKN8xiA5p5OJaG4UMzQR_Jzx2SsKOuUnKON_A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAE9FiQXk4abAzuKN8xiA5p5OJaG4UMzQR_Jzx2SsKOuUnKON_A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yinghai Lu <yinghai@kernel.org>
Cc: Gavin Shan <shangw@linux.vnet.ibm.com>, Sasha Levin <levinsasha928@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, David Miller <davem@davemloft.net>, hpa@linux.intel.com, linux-mm <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Wed, Jun 27, 2012 at 12:22:14PM -0700, Yinghai Lu wrote:
> On Wed, Jun 27, 2012 at 11:13 AM, Tejun Heo <tj@kernel.org> wrote:
> > Hello, Yinghai.
> >
> > Sorry about the delay.  I'm in bug storm somehow. :(
> >
> > On Fri, Jun 22, 2012 at 07:14:43PM -0700, Yinghai Lu wrote:
> >> On Fri, Jun 22, 2012 at 12:29 PM, Tejun Heo <tj@kernel.org> wrote:
> >> > I wish we had a single call - say, memblock_die(), or whatever - so
> >> > that there's a clear indication that memblock usage is done, but yeah
> >> > maybe another day.  Will review the patch itself.  BTW, can't you post
> >> > patches inline anymore?  Attaching is better than corrupt but is still
> >> > a bit annoying for review.
> >>
> >> please check the three patches:
> >
> > Heh, reviewing is cumbersome this way but here are my comments.
> >
> > * "[PATCH] memblock: free allocated memblock_reserved_regions later"
> >  looks okay to me.
> 
> Good, this one should go to 3.5, right?

Yes, I think so.

Thank you!

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
