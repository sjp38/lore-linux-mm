Date: Sat, 8 Feb 2003 19:53:15 -0500
From: Benjamin LaHaise <bcrl@redhat.com>
Subject: Re: Performance of highpte
Message-ID: <20030208195315.D2609@redhat.com>
References: <16010000.1044732573@[10.10.2.4]> <16730000.1044732785@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <16730000.1044732785@[10.10.2.4]>; from mbligh@aracnet.com on Sat, Feb 08, 2003 at 11:33:06AM -0800
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, Feb 08, 2003 at 11:33:06AM -0800, Martin J. Bligh wrote:
> Odd. linux-mm helpfully stripped the results ... I'll try once more below,
> if that doesn't work, try getting it off linux-kernel.

They weren't actually stripped, they somehow became part of the header.  
Hmmmm, now that I have a test message I can actually track down the 
problem.

		-ben
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
