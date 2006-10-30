Date: Mon, 30 Oct 2006 11:53:05 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 1/2] Create compat_sys_migrate_pages.
In-Reply-To: <20061030181701.23ea7cba.sfr@canb.auug.org.au>
Message-ID: <Pine.LNX.4.64.0610301152040.21342@schroedinger.engr.sgi.com>
References: <20061030181701.23ea7cba.sfr@canb.auug.org.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: LKML <linux-kernel@vger.kernel.org>, ppc-dev <linuxppc-dev@ozlabs.org>, paulus@samba.org, ak@suse.de, linux-mm@kvack.org, pj@sgi.com
List-ID: <linux-mm.kvack.org>

On Mon, 30 Oct 2006, Stephen Rothwell wrote:

> This is needed on bigendian 64bit architectures.
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Acked-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
