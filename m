Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id BAA07749
	for <linux-mm@kvack.org>; Tue, 25 Feb 2003 01:55:14 -0800 (PST)
Date: Tue, 25 Feb 2003 01:55:37 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.62-mm3 - no X for me
Message-Id: <20030225015537.4062825b.akpm@digeo.com>
In-Reply-To: <20030225094526.GA18857@gemtek.lt>
References: <20030223230023.365782f3.akpm@digeo.com>
	<3E5A0F8D.4010202@aitel.hist.no>
	<20030224121601.2c998cc5.akpm@digeo.com>
	<20030225094526.GA18857@gemtek.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zilvinas Valinskas <zilvinas@gemtek.lt>
Cc: helgehaf@aitel.hist.no, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave McCracken <dmccr@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Zilvinas Valinskas <zilvinas@gemtek.lt> wrote:
>
> On Mon, Feb 24, 2003 at 12:16:01PM -0800, Andrew Morton wrote:
> > Helge Hafting <helgehaf@aitel.hist.no> wrote:
> > >
> > > 2.5.62-mm3 boots up fine, but won't run X.  Something goes
> > > wrong switching to graphics so my monitor says "no signal"
> > > 
> >
> This is the boot messages and decoded ksymoops which happens when I try
> to log off and login as a different user in KDE3.1 (debian/unstable).
> 

Ah, thank you.

	kernel BUG at mm/rmap.c:248!

The fickle finger of fate points McCrackenwards.

> > Does 2.5.63 do the same thing?
> I haven't tried this yet.

2.5.63 should be OK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
