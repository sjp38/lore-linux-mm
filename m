Subject: Re: 2.5.68-mm2
From: Robert Love <rml@tech9.net>
In-Reply-To: <1509100000.1051117049@flay>
References: <20030423012046.0535e4fd.akpm@digeo.com>
	 <20030423095926.GJ8931@holomorphy.com> <1051116646.2756.2.camel@localhost>
	 <1509100000.1051117049@flay>
Content-Type: text/plain
Message-Id: <1051117874.2756.4.camel@localhost>
Mime-Version: 1.0
Date: 23 Apr 2003 13:11:14 -0400
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, Andrew Morton <akpm@digeo.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 2003-04-23 at 12:57, Martin J. Bligh wrote:

> Is this the bug that akpm was seeing, or a different one? The only 
> information I've seen (indirectly) is that fsx triggers the oops.

I cannot see this cause an oops, so no.

Just out-of-sync values resulting in an unexpected OOM or a delayed OOM.

	Robert Love

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
