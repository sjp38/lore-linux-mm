Date: Tue, 6 Mar 2007 17:52:46 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: don't use ZONE_DMA unless CONFIG_ZONE_DMA is set in
 setup.c
Message-Id: <20070306175246.b1253ec3.akpm@linux-foundation.org>
In-Reply-To: <45EDFEDB.3000507@debian.org>
References: <45EDFEDB.3000507@debian.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andres Salomon <dilinger@debian.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 06 Mar 2007 18:52:59 -0500
Andres Salomon <dilinger@debian.org> wrote:

> If CONFIG_ZONE_DMA is ever undefined, ZONE_DMA will also not be defined,
> and setup.c won't compile.  This wraps it with an #ifdef.
> 

I guess if anyone tries to disable ZONE_DMA on i386 they'll pretty quickly
discover that.  But I don't think we need to "fix" it yet?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
