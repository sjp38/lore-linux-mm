From: David Lang <david.lang@digitalinsight.com>
Date: Tue, 3 May 2005 17:51:43 -0700 (PDT)
Subject: Re: [RFC] how do we move the VM forward? (was Re: [RFC] cleanup
 ofuse-once)
In-Reply-To: <42781AC5.1000201@yahoo.com.au>
Message-ID: <Pine.LNX.4.62.0505031749010.12818@qynat.qvtvafvgr.pbz>
References: <Pine.LNX.4.61.0505030037100.27756@chimarrao.boston.redhat.com>
 <42771904.7020404@yahoo.com.au> <Pine.LNX.4.61.0505030913480.27756@chimarrao.boston.redhat.com>
 <42781AC5.1000201@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 4 May 2005, Nick Piggin wrote:

>
> Also having a box or two for running regression and stress
> testing is a must. I can do a bit here, but unfortunately
> "kernel compiles until it hurts" is probably not the best
> workload to target.
>
> In general most systems and their workloads aren't constantly
> swapping, so we should aim to minimise IO for normal
> workloads. Databases that use the pagecache (eg. postgresql)
> would be a good test. But again we don't want to focus on one
> thing.
>
> That said, of course we don't want to hurt the "really
> thrashing" case - and hopefully improve it if possible.

may I suggest useing OpenOffice as one test, it can eat up horrendous 
amounts of ram in operation (I have one spreadsheet I can send you if 
needed that takes 45min of cpu time on a Athlon64 3200 with 1G of ram just 
to open, at which time it shows openoffice takeing more then 512M of ram)

David Lang

-- 
There are two ways of constructing a software design. One way is to make it so simple that there are obviously no deficiencies. And the other way is to make it so complicated that there are no obvious deficiencies.
  -- C.A.R. Hoare
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
