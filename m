Message-ID: <20030722180125.54503.qmail@web12303.mail.yahoo.com>
Date: Tue, 22 Jul 2003 11:01:25 -0700 (PDT)
From: Ravi Krishnamurthy <kravi26@yahoo.com>
Subject: Re: Unable to boot 2.6.0-test1-mm2 (mm1 is OK) on RH 9.0.93 (Severn)
In-Reply-To: <1058887517.1668.16.camel@spc9.esa.lanl.gov>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Cole <elenstev@mesatop.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--- Steven Cole <elenstev@mesatop.com> wrote:
> I get this error when trying to boot 2.6.0-test1-mm2
> using the new Red
> Hat beta (Severn).  2.6.0-test2-mm2 runs successfully on
> a couple of
> other test boxes of mine.
> 
> VFS: Cannot open root device "hda1" or unknown-block(0,0)
> Please append a correct "root=" boot option
> Kernel panic: VFS: Unable to mount root fs on
> unknown-block(0,0)

 The last time I had this problem, I found that
CONFIG_IDEDISK_MULTI_MODE was off and my disk wouldn't
get recognized without that. But you say your other
kernels are working, so I am not sure this is the problem.

-Ravi.

__________________________________
Do you Yahoo!?
Yahoo! SiteBuilder - Free, easy-to-use web site design software
http://sitebuilder.yahoo.com
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
