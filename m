Date: Wed, 16 Apr 2008 12:12:20 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 2/4] Verify the page links and memory model
In-Reply-To: <20080416135138.1346.87095.sendpatchset@skynet.skynet.ie>
Message-ID: <Pine.LNX.4.64.0804161211140.14635@schroedinger.engr.sgi.com>
References: <20080416135058.1346.65546.sendpatchset@skynet.skynet.ie>
 <20080416135138.1346.87095.sendpatchset@skynet.skynet.ie>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, mingo@elte.hu, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 16 Apr 2008, Mel Gorman wrote:

> +		FLAGS_RESERVED);

FLAGS_RESERVED no longer exists in mm. Its dynamically calculated.

It may be useful to print out NR_PAGEFLAGS instead and show the area in 
the middle of page flags that is left unused and that may be used by 
arches such as sparc64.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
