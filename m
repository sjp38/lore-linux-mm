Subject: Re: [PATCH] page coloring for 2.5.59 kernel, version 1
References: <3.0.6.32.20030127224726.00806c20@boo.net>
	<884740000.1043737132@titus> <20030128071313.GH780@holomorphy.com>
	<1466000000.1043770007@titus>
From: Falk Hueffner <falk.hueffner@student.uni-tuebingen.de>
Date: 28 Jan 2003 17:41:23 +0100
In-Reply-To: <1466000000.1043770007@titus>
Message-ID: <87n0llfcr0.fsf@student.uni-tuebingen.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: William Lee Irwin III <wli@holomorphy.com>, Jason Papadopoulos <jasonp@boo.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

"Martin J. Bligh" <mbligh@aracnet.com> writes:

> > I think this one really needs to be done with the userspace cache
> > thrashing microbenchmarks. 
> 
> If a benefit cannot be show on some sort of semi-realistic workload,
> it's probably not worth it, IMHO.

I tested an earlier version on Alpha. While it didn't yield noticeable
performance benefits, it increased the reproducability of my benchmark
a lot, which is also pretty useful.

-- 
	Falk
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
