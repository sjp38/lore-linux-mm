Date: Tue, 8 Jan 2008 14:30:16 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 09/19] (NEW) more aggressively use lumpy reclaim
In-Reply-To: <20080108210007.257424941@redhat.com>
Message-ID: <Pine.LNX.4.64.0801081429150.4678@schroedinger.engr.sgi.com>
References: <20080108205939.323955454@redhat.com> <20080108210007.257424941@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mel@skynet.ie
List-ID: <linux-mm.kvack.org>

On Tue, 8 Jan 2008, Rik van Riel wrote:

> If normal pageout does not result in contiguous free pages for
> kernel stacks, fall back to lumpy reclaim instead of failing fork
> or doing excessive pageout IO.

Good. Ccing Mel. This is going to help higher order pages which is useful 
for a couple of other projects.

Reviewed-by: Christoph Lameter <clameter@sgi.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
