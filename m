Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id QAA19557
	for <linux-mm@kvack.org>; Thu, 27 Feb 2003 16:10:21 -0800 (PST)
Date: Thu, 27 Feb 2003 16:06:56 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: Rising io_load results Re: 2.5.63-mm1
Message-Id: <20030227160656.40ebeb93.akpm@digeo.com>
In-Reply-To: <200302281056.45501.kernel@kolivas.org>
References: <20030227025900.1205425a.akpm@digeo.com>
	<20030227134403.776bf2e3.akpm@digeo.com>
	<118810000.1046383273@baldur.austin.ibm.com>
	<200302281056.45501.kernel@kolivas.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Con Kolivas <kernel@kolivas.org>
Cc: dmccr@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Con Kolivas <kernel@kolivas.org> wrote:
>
> On Fri, 28 Feb 2003 09:01 am, Dave McCracken wrote:
> > --On Thursday, February 27, 2003 13:44:03 -0800 Andrew Morton
> >
> > <akpm@digeo.com> wrote:
> > >> ...
> > >> Mapped:       4294923652 kB
> > >
> > > Well that's gotta hurt.  This metric is used in making writeback
> > > decisions.  Probably the objrmap patch.
> >
> > Oops.  You're right.  Here's a patch to fix it.
> 
> Thanks. 
> 
> This looks better after a run:
> 
> MemTotal:       256156 kB
> ...
> Mapped:        4546752 kB

No, it is still wrong.  Mapped cannot exceed MemTotal.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
