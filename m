Date: Tue, 15 Aug 2006 03:27:40 -0700 (PDT)
Message-Id: <20060815.032740.10248213.davem@davemloft.net>
Subject: Re: [PATCH 1/1] network memory allocator.
From: David Miller <davem@davemloft.net>
In-Reply-To: <20060815100228.GC1092@2ka.mipt.ru>
References: <20060815002724.a635d775.akpm@osdl.org>
	<p738xlqa0aw.fsf@verdi.suse.de>
	<20060815100228.GC1092@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Tue, 15 Aug 2006 14:02:28 +0400
Return-Path: <owner-linux-mm@kvack.org>
To: johnpol@2ka.mipt.ru
Cc: ak@suse.de, akpm@osdl.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> I had a version with per-cpu data - it is not very convenient to use
> here with it's per_cpu_ptr dereferencings....

It does eat lots of space though, even for non-present cpus, and for
local cpu case the access may even get optimized to a single register
+ offset computation on some platforms :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
