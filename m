Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7A64928089F
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 11:52:17 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id v184so200702533pgv.6
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 08:52:17 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id f8si7552109pli.56.2017.02.08.08.52.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 08:52:16 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v18GmwCc144046
	for <linux-mm@kvack.org>; Wed, 8 Feb 2017 11:52:16 -0500
Received: from e32.co.us.ibm.com (e32.co.us.ibm.com [32.97.110.150])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28g0c7tr09-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 Feb 2017 11:52:15 -0500
Received: from localhost
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 8 Feb 2017 09:52:15 -0700
Date: Wed, 8 Feb 2017 08:52:11 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: PCID review?
Reply-To: paulmck@linux.vnet.ibm.com
References: <CALCETrVSiS22KLvYxZarexFHa3C7Z-ys_Lt2WV_63b4-tuRpQA@mail.gmail.com>
 <20170207210651.GB30506@linux.vnet.ibm.com>
 <CALCETrWA9vXktpw=56CoMhoqPQ6qSJbptUSTEeaW3vRCbVTvig@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrWA9vXktpw=56CoMhoqPQ6qSJbptUSTEeaW3vRCbVTvig@mail.gmail.com>
Message-Id: <20170208165211.GQ30506@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andy Lutomirski <luto@kernel.org>, Borislav Petkov <bp@alien8.de>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Feb 08, 2017 at 08:25:16AM -0800, Andy Lutomirski wrote:
> On Tue, Feb 7, 2017 at 1:06 PM, Paul E. McKenney
> <paulmck@linux.vnet.ibm.com> wrote:
> > On Tue, Feb 07, 2017 at 10:56:59AM -0800, Andy Lutomirski wrote:
> >> Quite a few people have expressed interest in enabling PCID on (x86)
> >> Linux.  Here's the code:
> >>
> >> https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/log/?h=x86/pcid
> >>
> >> The main hold-up is that the code needs to be reviewed very carefully.
> >> It's quite subtle.  In particular, "x86/mm: Try to preserve old TLB
> >> entries using PCID" ought to be looked at carefully to make sure the
> >> locking is right, but there are plenty of other ways this this could
> >> all break.
> >>
> >> Anyone want to take a look or maybe scare up some other reviewers?
> >> (Kees, you seemed *really* excited about getting this in.)
> >
> > Cool!
> >
> > So I can drop 61ec4c556b0d "rcu: Maintain special bits at bottom of
> > ->dynticks counter", correct?
> 
> Nope.  That's a different optimization.  If you consider that patch
> ready, want to email me, the dynticks folks, and linux-mm as a
> reminder?

Hmmm...  Good point.  I never have gotten any review feedback, and I
don't have a specific test for it.  Let me take another look at it.
There is probably something still broken.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
