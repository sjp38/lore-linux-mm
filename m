Date: Tue, 6 Mar 2007 23:02:48 -0500
From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] mm: don't use ZONE_DMA unless CONFIG_ZONE_DMA is set in setup.c
Message-ID: <20070307040248.GA30278@redhat.com>
References: <45EDFEDB.3000507@debian.org> <20070306175246.b1253ec3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070306175246.b1253ec3.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andres Salomon <dilinger@debian.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Mar 06, 2007 at 05:52:46PM -0800, Andrew Morton wrote:
 > On Tue, 06 Mar 2007 18:52:59 -0500
 > Andres Salomon <dilinger@debian.org> wrote:
 > 
 > > If CONFIG_ZONE_DMA is ever undefined, ZONE_DMA will also not be defined,
 > > and setup.c won't compile.  This wraps it with an #ifdef.
 > > 
 > 
 > I guess if anyone tries to disable ZONE_DMA on i386 they'll pretty quickly
 > discover that.  But I don't think we need to "fix" it yet?

CONFIG_ZONE_DMA isn't even optional on i386, so I'm curious how
you could hit this compile failure.

	Dave

-- 
http://www.codemonkey.org.uk

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
