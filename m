Date: Fri, 12 May 2006 16:19:21 +0200
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 0/3] Zone boundry alignment fixes
Message-ID: <20060512141921.GA564@elte.hu>
References: <445DF3AB.9000009@yahoo.com.au> <exportbomb.1147172704@pinky> <20060511005952.3d23897c.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20060511005952.3d23897c.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Andy Whitcroft <apw@shadowen.org>, nickpiggin@yahoo.com.au, haveblue@us.ibm.com, bob.picco@hp.com, mbligh@mbligh.org, ak@suse.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Andrew Morton <akpm@osdl.org> wrote:

> There's some possibility here of interaction with Mel's "patchset to 
> size zones and memory holes in an architecture-independent manner." I 
> jammed them together - let's see how it goes.

update: Andy's 3 patches, applied to 2.6.17-rc3-mm1, fixed all the 
crashes and asserts i saw. NUMA-on-x86 is now rock-solid on my testbox. 
Great work Andy!

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
