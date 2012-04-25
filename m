Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id D80FF6B0044
	for <linux-mm@kvack.org>; Wed, 25 Apr 2012 18:31:29 -0400 (EDT)
Date: Wed, 25 Apr 2012 18:31:21 -0400 (EDT)
Message-Id: <20120425.183121.1283820821646106475.davem@davemloft.net>
Subject: Re: [BUG]memblock: fix overflow of array index
From: David Miller <davem@davemloft.net>
In-Reply-To: <4F987ACB.8050604@linux.intel.com>
References: <CAHnt0GXW-pyOUuBLB1n6qBP4WNGpET9er_HbJ29s5j5DE1xAdA@mail.gmail.com>
	<20120425222819.GF8989@google.com>
	<4F987ACB.8050604@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@linux.intel.com
Cc: tj@kernel.org, htmldeveloper@gmail.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mingo@elte.hu, linux-mm@kvack.org

From: "H. Peter Anvin" <hpa@linux.intel.com>
Date: Wed, 25 Apr 2012 15:29:31 -0700

> On 04/25/2012 03:28 PM, Tejun Heo wrote:
>> 
>> All indexes in memblock are integers.  Changing that particular one to
>> unsigned int doesn't fix anything.  I think it just makes things more
>> confusing.  If there ever are cases w/ more then 2G memblocks, we're
>> going for 64bit not unsigned.
>> 
> 
> I would expect there to be plenty of memblocks larger than 2G?

Yes, but not the array indexes into those memblock entries, which is
what this patch is about.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
