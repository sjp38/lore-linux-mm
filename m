Date: Tue, 8 Jul 2003 22:19:41 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [announce, patch] 4G/4G split on x86, 64 GB RAM (and more) support
Message-ID: <20030709051941.GK15452@holomorphy.com>
References: <Pine.LNX.4.44.0307082332450.17252-100000@localhost.localdomain> <55580000.1057727591@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55580000.1057727591@[10.10.2.4]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Ingo Molnar <mingo@elte.hu>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

At some point in the past, mingo wrote:
>> i'm pleased to announce the first public release of the "4GB/4GB VM split"
>> patch, for the 2.5.74 Linux kernel:
>>    http://redhat.com/~mingo/4g-patches/4g-2.5.74-F8

On Tue, Jul 08, 2003 at 10:13:12PM -0700, Martin J. Bligh wrote:
> I presume this was for -bk something as it applies clean to -bk6, but not
> virgin. 
> However, it crashes before console_init on NUMA ;-( I'll shove early printk
> in there later.

Don't worry, I'm debugging it.


-- wli
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
