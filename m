Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0116B6B0005
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 12:28:46 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id i3so5256985wmf.7
        for <linux-mm@kvack.org>; Mon, 30 Apr 2018 09:28:45 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q7-v6si3320116edl.96.2018.04.30.09.28.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Apr 2018 09:28:44 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w3UGSftF071201
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 12:28:43 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2hp3v50b6h-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 30 Apr 2018 12:28:42 -0400
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <linuxram@us.ibm.com>;
	Mon, 30 Apr 2018 17:28:32 +0100
Date: Mon, 30 Apr 2018 09:28:23 -0700
From: Ram Pai <linuxram@us.ibm.com>
Subject: Re: [PATCH 0/9] [v3] x86, pkeys: two protection keys bug fixes
Reply-To: Ram Pai <linuxram@us.ibm.com>
References: <20180427174527.0031016C@viggo.jf.intel.com>
 <20180428070553.yjlt22sb6ntcaqnc@gmail.com>
 <a176ae33-eb01-d275-f372-a33829e865a7@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <a176ae33-eb01-d275-f372-a33829e865a7@intel.com>
Message-Id: <20180430162823.GB5666@ram.oc3035372033.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Ingo Molnar <mingo@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, tglx@linutronix.de, mpe@ellerman.id.au, akpm@linux-foundation.org, shuah@kernel.org, shakeelb@google.com

On Mon, Apr 30, 2018 at 08:30:43AM -0700, Dave Hansen wrote:
> On 04/28/2018 12:05 AM, Ingo Molnar wrote:
> > In the above kernel that was missing the PROT_EXEC fix I was repeatedly running 
> > the 64-bit and 32-bit testcases as non-root and as root as well, until I got a 
> > hang in the middle of a 32-bit test running as root:
> > 
> >   test  7 PASSED (iteration 19)
> >   test  8 PASSED (iteration 19)
> >   test  9 PASSED (iteration 19)
> > 
> >   < test just hangs here >
> 
> For the hang, there is a known issue with the use of printf() in the
> signal handler and a resulting deadlock.  I *thought* there was a patch
> merged to fix this from Ram Pai or one of the other IBM folks.

Yes. there is a patch. unfortunately that patch assumes the selftest has
been moved into selftests/vm directory.  One option is --  I merge your
changes in my selftest patchset, and send the entire series for upstream
merge.

Or you can manually massage-in the specific fix.
The patch is "selftests/vm: Fix deadlock in protection_keys.c"
https://patchwork.ozlabs.org/patch/864394/

Let me know,
-- 
Ram Pai
