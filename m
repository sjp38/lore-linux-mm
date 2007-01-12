Date: Thu, 11 Jan 2007 23:25:22 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH/RFC 2.6.20-rc4 1/1] fbdev,mm: hecuba/E-Ink fbdev driver
Message-Id: <20070111232522.491e57fb.akpm@osdl.org>
In-Reply-To: <1168586145.26496.35.camel@twins>
References: <20070111142427.GA1668@localhost>
	<20070111133759.d17730a4.akpm@osdl.org>
	<45a44e480701111622i32fffddcn3b4270d539620743@mail.gmail.com>
	<1168586145.26496.35.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Jaya Kumar <jayakumar.lkml@gmail.com>, linux-fbdev-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 12 Jan 2007 08:15:45 +0100
Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:

> How about implementing the sync_page() aop?

That got deleted in Jens's tree - the unplugging rework.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
