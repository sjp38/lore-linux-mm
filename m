Message-ID: <41AEBAB9.3050705@pobox.com>
Date: Thu, 02 Dec 2004 01:48:25 -0500
From: Jeff Garzik <jgarzik@pobox.com>
MIME-Version: 1.0
Subject: Re: page fault scalability patch V12 [0/7]: Overview and performance
 tests
References: <Pine.LNX.4.44.0411221457240.2970-100000@localhost.localdomain>	<Pine.LNX.4.58.0411221343410.22895@schroedinger.engr.sgi.com>	<Pine.LNX.4.58.0411221419440.20993@ppc970.osdl.org>	<Pine.LNX.4.58.0411221424580.22895@schroedinger.engr.sgi.com>	<Pine.LNX.4.58.0411221429050.20993@ppc970.osdl.org>	<Pine.LNX.4.58.0412011539170.5721@schroedinger.engr.sgi.com>	<Pine.LNX.4.58.0412011608500.22796@ppc970.osdl.org>	<41AEB44D.2040805@pobox.com> <20041201223441.3820fbc0.akpm@osdl.org>
In-Reply-To: <20041201223441.3820fbc0.akpm@osdl.org>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: torvalds@osdl.org, clameter@sgi.com, hugh@veritas.com, benh@kernel.crashing.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> We need to be be achieving higher-quality major releases than we did in
> 2.6.8 and 2.6.9.  Really the only tool we have to ensure this is longer
> stabilisation periods.


I'm still hoping that distros (like my employer) and orgs like OSDL will 
step up, and hook 2.6.x BK snapshots into daily test harnesses.

Something like John Cherry's reports to lkml on warnings and errors 
would be darned useful.  His reports are IMO an ideal model:  show 
day-to-day _changes_ in test results.  Don't just dump a huge list of 
testsuite results, results which are often clogged with expected 
failures and testsuite bug noise.

	Jeff


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
