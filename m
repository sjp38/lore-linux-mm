Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id 0A4036B0005
	for <linux-mm@kvack.org>; Mon, 11 Feb 2013 12:48:04 -0500 (EST)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <dave@linux.vnet.ibm.com>;
	Mon, 11 Feb 2013 12:48:00 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 0D2696E8AEC
	for <linux-mm@kvack.org>; Mon, 11 Feb 2013 12:32:48 -0500 (EST)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r1BHWnPU284926
	for <linux-mm@kvack.org>; Mon, 11 Feb 2013 12:32:49 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r1BHWljG016743
	for <linux-mm@kvack.org>; Mon, 11 Feb 2013 15:32:49 -0200
Message-ID: <51192B39.9060501@linux.vnet.ibm.com>
Date: Mon, 11 Feb 2013 09:32:41 -0800
From: Dave Hansen <dave@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] add helper for highmem checks
References: <20130208202813.62965F25@kernel.stglabs.ibm.com> <20130209094121.GB17728@pd.tnic> <20130209104751.GC17728@pd.tnic>
In-Reply-To: <20130209104751.GC17728@pd.tnic>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hpa@zytor.com, mingo@kernel.org, tglx@linutronix.de

On 02/09/2013 02:47 AM, Borislav Petkov wrote:
> On Sat, Feb 09, 2013 at 10:41:21AM +0100, Borislav Petkov wrote:
> With this change, they definitely fix something because I even get X on
> the box started. Previously, it would spit out the warning and wouldn't
> start X with the login window. And my suspicion is that wdm (WINGs
> display manager) I'm using, does /dev/mem accesses when it starts and it
> obviously failed. Now not so much :-)

That's crazy.  Didn't expect that at all.

I guess X is happier getting an error than getting random pages back.
I'm working on a set of patches now that should get it _working_ instead
of just returning an error.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
