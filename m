Subject: Re: [patch] generic nonlinear mappings, 2.5.44-mm2-D0
From: Bryan O'Sullivan <bos@serpentine.com>
In-Reply-To: <Pine.LNX.4.44.0210222237180.22860-100000@localhost.localdomain>
References: <Pine.LNX.4.44.0210222237180.22860-100000@localhost.localdomain>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 23 Oct 2002 12:09:52 -0700
Message-Id: <1035400192.13194.2.camel@plokta.s8.com>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrew Morton <akpm@digeo.com>, Christoph Hellwig <hch@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2002-10-22 at 13:42, Ingo Molnar wrote:

> I think ext2/ext3fs's current 2Tb/4Tb limit is a much
> bigger problem, you cannot compile around that - are there any patches in
> fact that lift that limit? (well, one solution is to use another
> filesystem.)

Peter Chubb's sector_t changes effectively raise this to an 8TB limit in
2.5.x.  The limit would be 16TB, but ext3 and jbd are rather cavalier
with casting block offsets between int, long, and unsigned long. 
Changes to fix that would be highly intrusive.

	<b

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
