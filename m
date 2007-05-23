Date: Tue, 22 May 2007 21:16:24 -0700 (PDT)
Message-Id: <20070522.211624.102772043.davem@davemloft.net>
Subject: Re: [PATCH 0/8] Sparsemem Virtual Memmap V4
From: David Miller <davem@davemloft.net>
In-Reply-To: <exportbomb.1179873917@pinky>
References: <exportbomb.1179873917@pinky>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Andy Whitcroft <apw@shadowen.org>
Date: Tue, 22 May 2007 23:57:55 +0100
Return-Path: <owner-linux-mm@kvack.org>
To: apw@shadowen.org
Cc: linux-mm@kvack.org, linux-arch@vger.kernel.org, npiggin@suse.de, clameter@sgi.com, mel@csn.ul.ie
List-ID: <linux-mm.kvack.org>

> This stack is against v2.6.22-rc1-mm1.  It has been compile, boot
> and lightly tested on x86_64, ia64 and PPC64.  Sparc64 as been
> compiled but not booted.

Sparc64 boot tested successfully on Niagara t1000 with 26 cpus.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
