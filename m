Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5D9866B00B4
	for <linux-mm@kvack.org>; Fri,  7 Jan 2011 11:56:44 -0500 (EST)
Date: Fri, 7 Jan 2011 17:56:32 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Very large memory configurations:   > 16 TB
Message-ID: <20110107165632.GA7088@elte.hu>
References: <20110106170942.GA8253@sgi.com>
 <20110107125135.GD20761@elte.hu>
 <alpine.DEB.2.00.1101071027040.3014@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1101071027040.3014@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>


* Christoph Lameter <cl@linux.com> wrote:

> Andi put a description of the memory layout in
> Documentation/x86/x86_64/mm.txt. Seems to indicate that 64 TB was
> considered as a maximum when the memory layout for x86_64 was set up:

Yes, that document was rather incomplete and does not really answer Jack's 
questions, that's why i sent this more complete description originally:

  http://lkml.indiana.edu/hypermail/linux/kernel/0812.2/00292.html

a few years ago, answering a similar question.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
