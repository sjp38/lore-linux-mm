Subject: Re: [RFC][PATCH 0/6] Critical Page Pool
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <43A04A38.6020403@us.ibm.com>
References: <439FCECA.3060909@us.ibm.com>
	 <20051214100841.GA18381@elf.ucw.cz> <20051214120152.GB5270@opteron.random>
	 <1134565436.25663.24.camel@localhost.localdomain>
	 <43A04A38.6020403@us.ibm.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: Wed, 14 Dec 2005 19:17:06 +0000
Message-Id: <1134587827.25663.69.camel@localhost.localdomain>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Dobson <colpatch@us.ibm.com>
Cc: Andrea Arcangeli <andrea@suse.de>, Pavel Machek <pavel@suse.cz>, linux-kernel@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mer, 2005-12-14 at 08:37 -0800, Matthew Dobson wrote:
> Actually, Sridhar's code (mentioned earlier in this thread) *does* drop
> incoming packets that are not 'critical', but unfortunately you need to

I realise that but if you look at the previous history in 2.0 and 2.2
this was all that was ever needed. It thus begs the question why all the
extra support and logic this time around ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
