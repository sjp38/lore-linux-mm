Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E478C6B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 16:06:59 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id t18so27660793wmt.7
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 13:06:59 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id n14si453148wmd.11.2017.02.07.13.06.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 13:06:58 -0800 (PST)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v17L3rcA139112
	for <linux-mm@kvack.org>; Tue, 7 Feb 2017 16:06:57 -0500
Received: from e37.co.us.ibm.com (e37.co.us.ibm.com [32.97.110.158])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28fmmd31pq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 07 Feb 2017 16:06:57 -0500
Received: from localhost
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Tue, 7 Feb 2017 14:06:55 -0700
Date: Tue, 7 Feb 2017 13:06:51 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: PCID review?
Reply-To: paulmck@linux.vnet.ibm.com
References: <CALCETrVSiS22KLvYxZarexFHa3C7Z-ys_Lt2WV_63b4-tuRpQA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrVSiS22KLvYxZarexFHa3C7Z-ys_Lt2WV_63b4-tuRpQA@mail.gmail.com>
Message-Id: <20170207210651.GB30506@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>, Kees Cook <keescook@chromium.org>, Dave Hansen <dave.hansen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Feb 07, 2017 at 10:56:59AM -0800, Andy Lutomirski wrote:
> Quite a few people have expressed interest in enabling PCID on (x86)
> Linux.  Here's the code:
> 
> https://git.kernel.org/cgit/linux/kernel/git/luto/linux.git/log/?h=x86/pcid
> 
> The main hold-up is that the code needs to be reviewed very carefully.
> It's quite subtle.  In particular, "x86/mm: Try to preserve old TLB
> entries using PCID" ought to be looked at carefully to make sure the
> locking is right, but there are plenty of other ways this this could
> all break.
> 
> Anyone want to take a look or maybe scare up some other reviewers?
> (Kees, you seemed *really* excited about getting this in.)

Cool!

So I can drop 61ec4c556b0d "rcu: Maintain special bits at bottom of
->dynticks counter", correct?

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
