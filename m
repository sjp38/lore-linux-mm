Date: Sat, 5 Apr 2003 14:31:38 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: objrmap and vmtruncate
Message-Id: <20030405143138.27003289.akpm@digeo.com>
In-Reply-To: <20030405220621.GG1326@dualathlon.random>
References: <20030404163154.77f19d9e.akpm@digeo.com>
	<12880000.1049508832@flay>
	<20030405024414.GP16293@dualathlon.random>
	<20030404192401.03292293.akpm@digeo.com>
	<20030405040614.66511e1e.akpm@digeo.com>
	<20030405163003.GD1326@dualathlon.random>
	<20030405132406.437b27d7.akpm@digeo.com>
	<20030405220621.GG1326@dualathlon.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: mbligh@aracnet.com, mingo@elte.hu, hugh@veritas.com, dmccr@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrea Arcangeli <andrea@suse.de> wrote:
>
> I see what you mean, you're right. That's because all the 10,000 vma
> belongs to the same inode.

I see two problems with objrmap - this search, and the complexity of the
interworking with nonlinear mappings.

There is talk going around about implementing some more sophisticated search
structure thatn a linear list.

And treating the nonlinear mappings as being mlocked is a great
simplification - I'd be interested in Ingo's views on that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
