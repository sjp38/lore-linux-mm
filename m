Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id SAA12551
	for <linux-mm@kvack.org>; Sat, 21 Sep 2002 18:07:03 -0700 (PDT)
Message-ID: <3D8D17B6.D4E1ECAE@digeo.com>
Date: Sat, 21 Sep 2002 18:07:02 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: overcommit stuff
References: <3D8D066F.1B45E3EA@digeo.com> <Pine.LNX.4.44.0209220129310.2339-100000@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Hugh Dickins wrote:
> 
> ...
> > It seems very unlikely (impossible?) that those pages will
> > ever become unshared.
> 
> I expect it's very unlikely (short of application bugs) that
> those pages would become unshared; but they have been mapped
> in such a way that the process is entitled to unshare them,
> therefore they have been counted.  A good example of why
> Linux does not impose strict commit accounting, and why
> you may choose not to use Alan's strict accounting policy.
> 

OK, thanks.   Just checking.

Is glibc mapping executables with PROT_WRITE?  If so,
doesn't that rather devalue the whole overcommit thing?
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
