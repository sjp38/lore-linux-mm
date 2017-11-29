Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5717E6B0038
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 15:51:08 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id r51so3088408qtj.17
        for <linux-mm@kvack.org>; Wed, 29 Nov 2017 12:51:08 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l5si2651432qtf.461.2017.11.29.12.51.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Nov 2017 12:51:07 -0800 (PST)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id vATKnbhM146670
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 15:51:06 -0500
Received: from e18.ny.us.ibm.com (e18.ny.us.ibm.com [129.33.205.208])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2ej205nykm-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 29 Nov 2017 15:51:05 -0500
Received: from localhost
	by e18.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 29 Nov 2017 15:51:02 -0500
Date: Wed, 29 Nov 2017 12:50:59 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: WARNING: suspicious RCU usage (3)
Reply-To: paulmck@linux.vnet.ibm.com
References: <94eb2c03c9bcc3b127055f11171d@google.com>
 <20171128133026.cf03471c99d7a0c827c5a21c@linux-foundation.org>
 <20171128223041.GZ3624@linux.vnet.ibm.com>
 <CACT4Y+YLi5qw1z4t4greG05n_2NL3mpXjhT7F-Kh-YeN4HWC3g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+YLi5qw1z4t4greG05n_2NL3mpXjhT7F-Kh-YeN4HWC3g@mail.gmail.com>
Message-Id: <20171129205059.GI3624@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, syzbot <bot+73a7bec1bc0f4fc0512a246334081f8c671762a8@syzkaller.appspotmail.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, syzkaller-bugs@googlegroups.com, Herbert Xu <herbert@gondor.apana.org.au>

On Wed, Nov 29, 2017 at 07:25:32AM +0100, Dmitry Vyukov wrote:
> On Tue, Nov 28, 2017 at 11:30 PM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> > On Tue, Nov 28, 2017 at 01:30:26PM -0800, Andrew Morton wrote:
> >> On Tue, 28 Nov 2017 12:45:01 -0800 syzbot <bot+73a7bec1bc0f4fc0512a246334081f8c671762a8@syzkaller.appspotmail.com> wrote:
> >>
> >> > Hello,
> >> >
> >> > syzkaller hit the following crash on
> >> > b0a84f19a5161418d4360cd57603e94ed489915e
> >> > git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git/master
> >> > compiler: gcc (GCC) 7.1.1 20170620
> >> > .config is attached
> >> > Raw console output is attached.
> >> >
> >> > Unfortunately, I don't have any reproducer for this bug yet.
> >> >
> >> > WARNING: suspicious RCU usage
> >>
> >> There's a bunch of other info which lockdep_rcu_suspicious() should
> >> have printed out, but this trace doesn't have any of it.  I wonder why.
> >
> > Yes, there should be more info printed, no idea why it would go missing.
> 
> I think that's because while reporting "suspicious RCU usage" kernel hit:
> 
> BUG: unable to handle kernel NULL pointer dereference at 0000000000000074
> 
> and the rest of the report is actually about the NULL deref.
> 
> syzkaller hits too many crashes at the same time. And it's a problem
> for us. We get reports with corrupted/intermixed titles,
> corrupted/intermixed bodies, reports with same titles but about
> different bugs, etc.

Got it, thank you!

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
