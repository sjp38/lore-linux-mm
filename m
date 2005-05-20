Date: Fri, 20 May 2005 14:24:27 -0700
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: [RFC] how do we move the VM forward? (was Re: [RFC] cleanup ofuse-once)
Message-ID: <89480000.1116624266@flay>
In-Reply-To: <20050520181606.GB6002@MAIL.13thfloor.at>
References: <Pine.LNX.4.61.0505030037100.27756@chimarrao.boston.redhat.com> <42771904.7020404@yahoo.com.au> <Pine.LNX.4.61.0505030913480.27756@chimarrao.boston.redhat.com> <42781AC5.1000201@yahoo.com.au> <Pine.LNX.4.62.0505031749010.12818@qynat.qvtvafvgr.pbz> <20050520181606.GB6002@MAIL.13thfloor.at>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Herbert Poetzl <herbert@13thfloor.at>, David Lang <david.lang@digitalinsight.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


--On Friday, May 20, 2005 20:16:06 +0200 Herbert Poetzl <herbert@13thfloor.at> wrote:

> On Tue, May 03, 2005 at 05:51:43PM -0700, David Lang wrote:
>> On Wed, 4 May 2005, Nick Piggin wrote:
>> 
>> > 
>> > Also having a box or two for running regression and stress
>> > testing is a must. I can do a bit here, but unfortunately
>> > "kernel compiles until it hurts" is probably not the best
>> > workload to target.
> 
> if there are some tests or output (kernel logs, etc)
> or proc info or vmstat or whatever, which doesn't take
> 100% cpu time, I'm able and willing to test it on different
> workloads (including compiling the kernel until it hurts ;)

I did take that patch and run a bunch of tests on it across a few
different architectures. everything worked fine, no perf differnences
either way ... but then I may not have actually put it under memory
pressure, so it might not be ideal testing ;-)

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
