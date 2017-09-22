Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5E3966B0038
	for <linux-mm@kvack.org>; Fri, 22 Sep 2017 13:18:44 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id i14so2247877qke.6
        for <linux-mm@kvack.org>; Fri, 22 Sep 2017 10:18:44 -0700 (PDT)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id k96si232263qte.461.2017.09.22.10.18.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 Sep 2017 10:18:43 -0700 (PDT)
Date: Fri, 22 Sep 2017 10:18:26 -0700
From: Roman Gushchin <guro@fb.com>
Subject: Re: [RESEND] proc, coredump: add CoreDumping flag to /proc/pid/status
Message-ID: <20170922171826.GA1712@castle.DHCP.thefacebook.com>
References: <20170914224431.GA9735@castle>
 <20170920230634.31572-1-guro@fb.com>
 <CALYGNiMOPMrY1+kN=vC4nyD3OG1T1VWSNVTROvPvH2Tchk0z_g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <CALYGNiMOPMrY1+kN=vC4nyD3OG1T1VWSNVTROvPvH2Tchk0z_g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Alexander Viro <viro@zeniv.linux.org.uk>, Ingo Molnar <mingo@kernel.org>, kernel-team@fb.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Oleg Nesterov <oleg@redhat.com>

On Fri, Sep 22, 2017 at 06:44:12PM +0300, Konstantin Khlebnikov wrote:
> On Thu, Sep 21, 2017 at 2:06 AM, Roman Gushchin <guro@fb.com> wrote:
> > Right now there is no convenient way to check if a process is being
> > coredumped at the moment.
> >
> > It might be necessary to recognize such state to prevent killing
> > the process and getting a broken coredump.
> > Writing a large core might take significant time, and the process
> > is unresponsive during it, so it might be killed by timeout,
> > if another process is monitoring and killing/restarting
> > hanging tasks.
> >
> > To provide an ability to detect if a process is in the state of
> > being coreduped, we can expose a boolean CoreDumping flag
> > in /proc/pid/status.
> 
> Makes sense.
> 
> Maybe print this line only when task actually makes dump?

I don't think we do this trick with any other fields...

> And probably expose pid of coredump helper.

It will be racy in most cases, so I'm not sure it worth it.
What's the usecase?
In any case, it sounds like a separate feature.

> 
> Add Oleg into CC.

Thank you!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
