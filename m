Date: Sun, 15 Sep 2002 10:26:08 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [PATCH] add vmalloc stats to meminfo
Message-ID: <20020915172608.GJ3530@holomorphy.com>
References: <20020915071157.GH3530@holomorphy.com> <Pine.LNX.4.44.0209151021530.3517-100000@shell1.aracnet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0209151021530.3517-100000@shell1.aracnet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "M. Edward (Ed) Borasky" <znmeb@aracnet.com>
Cc: Andrew Morton <akpm@digeo.com>, Dave Hansen <haveblue@us.ibm.com>, "Martin J. Bligh" <Martin.Bligh@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 15 Sep 2002, William Lee Irwin III wrote:
>> Also, dynamic vmalloc allocations may very well be starved by boot-time
>> allocations on systems where much vmallocspace is required for IO memory.
>> The failure mode of such is effectively deadlock, since they block
>> indefinitely waiting for permanent boot-time allocations to be freed up.

On Sun, Sep 15, 2002 at 10:23:24AM -0700, M. Edward (Ed) Borasky wrote:
> Thank you!! How difficult would it be to back-port this to 2.4.18?

Note the follow-up to this saying that the above paragraph was incorrect.
It doesn't sleep except to allocate backing memmory.


Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
