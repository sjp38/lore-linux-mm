Date: Mon, 9 Apr 2007 14:41:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [QUICKLIST 1/4] Quicklists for page table pages V5
Message-Id: <20070409144107.21287fb8.akpm@linux-foundation.org>
In-Reply-To: <20070409182509.8559.33823.sendpatchset@schroedinger.engr.sgi.com>
References: <20070409182509.8559.33823.sendpatchset@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, ak@suse.de
List-ID: <linux-mm.kvack.org>

On Mon,  9 Apr 2007 11:25:09 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> Quicklists for page table pages V5

So... we skipped i386 this time?

I'd have gone squeamish if it was included, due to the mystery crash when
we (effectively) set the list size to zero.  Someone(tm) should look into 
that - who knows, it might indicate a problem in generic code.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
