Subject: Re: 2.6.1-rc2-mm1
From: Robert Love <rml@ximian.com>
In-Reply-To: <3FFDFEB3.3010301@yahoo.es>
References: <20040107232831.13261f76.akpm@osdl.org>
	 <1073593346.1618.3.camel@moria.arnor.net>
	 <1073594795.1738.2.camel@moria.arnor.net>  <3FFDFEB3.3010301@yahoo.es>
Content-Type: text/plain
Message-Id: <1073610855.1228.23.camel@localhost>
Mime-Version: 1.0
Date: Thu, 08 Jan 2004 20:14:16 -0500
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roberto Sanchez <rcsanchez97@yahoo.es>
Cc: Andrew Morton <akpm@osdl.org>, Linux-Kernel List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2004-01-08 at 20:06, Roberto Sanchez wrote:

> I get hard lockups during boot up, in X, and when starting big apps
> (mozilla, OOo, Neverwinter Nights, etc).  I reverted to -rc1-mm1.

There is a nasty bug in the poll code, I think.

	Robert Love


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
