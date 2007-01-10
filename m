Date: Wed, 10 Jan 2007 15:04:15 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [REGRESSION] 2.6.19/2.6.20-rc3 buffered write slowdown
In-Reply-To: <20070110223731.GC44411608@melbourne.sgi.com>
Message-ID: <Pine.LNX.4.64.0701101503310.22578@schroedinger.engr.sgi.com>
References: <20070110223731.GC44411608@melbourne.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Chinner <dgc@sgi.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Jan 2007, David Chinner wrote:

> The performance and smoothness is fully restored on 2.6.20-rc3
> by setting dirty_ratio down to 10 (from the default 40), so
> something in the VM is not working as well as it used to....

dirty_background_ratio is left as is at 10? So you gain performance
by switching off background writes via pdflush?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
