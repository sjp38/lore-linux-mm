Date: Fri, 27 Sep 2002 15:54:55 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: 2.5.38-mm3
Message-ID: <20020927225455.GW22942@holomorphy.com>
References: <20020927152833.D25021@in.ibm.com> <502559422.1033113869@[10.10.2.3]> <20020927224424.A28529@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <20020927224424.A28529@in.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dipankar Sarma <dipankar@in.ibm.com>
Cc: "Martin J. Bligh" <mbligh@aracnet.com>, Zwane Mwaikambo <zwane@linuxpower.ca>, Andrew Morton <akpm@digeo.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Fri, Sep 27, 2002 at 10:44:24PM +0530, Dipankar Sarma wrote:
> Not sure why it shows up more in -mm, but likely because -mm has
> lot less contention on other locks like dcache_lock.

Well, the profile I posted was an interactive UP workload, and it's
fairly high there. Trimming cycles off this is good for everyone.

Small SMP boxen (dual?) used similarly will probably see additional
gains as the number of locked operations in fget() will be reduced.
There's clearly no contention or cacheline bouncing in my workloads as
none of them have tasks sharing file tables, nor is anything else
messing with the cachelines.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
