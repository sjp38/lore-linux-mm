Date: Tue, 22 Jan 2008 15:00:17 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: SLUB: Increasing partial pages
In-Reply-To: <20080122223541.GR27250@parisc-linux.org>
Message-ID: <Pine.LNX.4.64.0801221458260.2271@schroedinger.engr.sgi.com>
References: <20080116195949.GO18741@parisc-linux.org>
 <Pine.LNX.4.64.0801161219050.9694@schroedinger.engr.sgi.com>
 <20080116214127.GA11559@parisc-linux.org> <Pine.LNX.4.64.0801161347160.11353@schroedinger.engr.sgi.com>
 <20080116221618.GB11559@parisc-linux.org> <Pine.LNX.4.64.0801161421240.12024@schroedinger.engr.sgi.com>
 <20080118191430.GD20490@parisc-linux.org> <Pine.LNX.4.64.0801221142330.27692@schroedinger.engr.sgi.com>
 <20080122223541.GR27250@parisc-linux.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matthew Wilcox <matthew@wil.cx>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 22 Jan 2008, Matthew Wilcox wrote:

> I also don't understand the dependency tree -- you seem to be saying
> that we could apply patch 6 without patches 1-5 and test that.

You could do that. Many patches can be moved at will, some require minor 
mods to apply.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
