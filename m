Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx157.postini.com [74.125.245.157])
	by kanga.kvack.org (Postfix) with SMTP id EC90C6B0033
	for <linux-mm@kvack.org>; Fri, 31 May 2013 01:35:10 -0400 (EDT)
Message-ID: <51A8368C.8090006@sandeen.net>
Date: Fri, 31 May 2013 00:35:08 -0500
From: Eric Sandeen <sandeen@sandeen.net>
MIME-Version: 1.0
Subject: Re: 3.9.4 Oops running xfstests (WAS Re: 3.9.3: Oops running xfstests)
References: <510292845.4997401.1369279175460.JavaMail.root@redhat.com> <1985929268.4997720.1369279277543.JavaMail.root@redhat.com> <20130523035115.GY24543@dastard> <986348673.5787542.1369385526612.JavaMail.root@redhat.com> <20130527053608.GS29466@dastard> <1588848128.8530921.1369885528565.JavaMail.root@redhat.com> <20130530052049.GK29466@dastard> <1824023060.8558101.1369892432333.JavaMail.root@redhat.com> <1462663454.9294499.1369969415681.JavaMail.root@redhat.com>
In-Reply-To: <1462663454.9294499.1369969415681.JavaMail.root@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: CAI Qian <caiqian@redhat.com>
Cc: Dave Chinner <david@fromorbit.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org, xfs@oss.sgi.com

On 5/30/13 10:03 PM, CAI Qian wrote:
> OK, so the minimal workload to trigger this I found so far was to
> run trinity, ltp and then xfstests. I have been able to easily
> reproduced on 3 servers so far, and I'll post full logs here for
> LKML and linux-mm as this may unrelated to XFS only. As far as
> I can tell from the previous testing results, this has never been
> reproduced back in 3.9 GA time. This seems also been reproduced
> on 3.10-rc3 mostly on s390x so far.
> CAI Qian
> 

Can you hit it w/o trinity?   I ask because trinity's stated
goal is to fuzz and corrupt, right - so it's quite possible
that blowing up later in xfs is a side effect?

-Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
