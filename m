From: Badari Pulavarty <pbadari@us.ibm.com>
Message-Id: <200210031621.g93GLJb12018@eng2.beaverton.ibm.com>
Subject: Re: [Lse-tech] 2.5.40-mm1 - runalltests - 95.89% pass
Date: Thu, 3 Oct 2002 09:21:19 -0700 (PDT)
In-Reply-To: <1033661465.14606.13.camel@plars> from "Paul Larson" at Oct 03, 2002 10:11:02 AM PST
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Larson <plars@linuxtestproject.org>
Cc: linux-mm <linux-mm@kvack.org>, lse-tech <lse-tech@lists.sourceforge.net>, ltp-results <ltp-results@lists.sourceforge.net>
List-ID: <linux-mm.kvack.org>

> 
> Sorry I havn't had time to look at the -mm kernels in a while, I'll try
> to keep up with them better.
> 
> Attached are a list of LTP failures for 2.5.40-mm1 with ltp-20020910. 
> All are known issues such as the pread/pwrite glibc stuff and the
> readv/writev new behaviour (the ltp release next month will address that
> for new kernels).  The dio tests failed of course, since the fs was
> ext3.  It's my understanding that dio isn't supported in ext3 yet but
> please correct me if this is not true.
> 

No !! DIO is supported on ext3 (in 2.5.40-mm1).


- Badari
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
