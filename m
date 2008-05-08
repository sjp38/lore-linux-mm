Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m48Esh2V000567
	for <linux-mm@kvack.org>; Thu, 8 May 2008 10:54:43 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m48EqYqZ247296
	for <linux-mm@kvack.org>; Thu, 8 May 2008 10:52:34 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m48EqXs3014182
	for <linux-mm@kvack.org>; Thu, 8 May 2008 10:52:33 -0400
Subject: Re: [PATCH] x86: fix PAE pmd_bad bootup warning
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20080508143453.GE12654@escobedo.amd.com>
References: <b6a2187b0805051806v25fa1272xb08e0b70b9c3408@mail.gmail.com>
	 <20080506124946.GA2146@elte.hu>
	 <Pine.LNX.4.64.0805061435510.32567@blonde.site>
	 <alpine.LFD.1.10.0805061138580.32269@woody.linux-foundation.org>
	 <Pine.LNX.4.64.0805062043580.11647@blonde.site>
	 <20080506202201.GB12654@escobedo.amd.com>
	 <1210106579.4747.51.camel@nimitz.home.sr71.net>
	 <20080508143453.GE12654@escobedo.amd.com>
Content-Type: text/plain
Date: Thu, 08 May 2008 07:52:30 -0700
Message-Id: <1210258350.7905.45.camel@nimitz.home.sr71.net>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hans Rosenfeld <hans.rosenfeld@amd.com>
Cc: Hugh Dickins <hugh@veritas.com>, Ingo Molnar <mingo@elte.hu>, Jeff Chua <jeff.chua.linux@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Gabriel C <nix.or.die@googlemail.com>, Arjan van de Ven <arjan@linux.intel.com>, Nishanth Aravamudan <nacc@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-05-08 at 16:34 +0200, Hans Rosenfeld wrote:
> While trying to reproduce this, I noticed that the huge page wouldn't
> leak when I just mmapped it and exited without explicitly unmapping, as
> I described before. The huge page is leaked only when the
> /proc/self/pagemap entry for the huge page is read.

Well, that's an interesting data point! :)

Are you running any of your /proc/<pid>/pagemap patches?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
