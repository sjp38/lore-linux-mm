Message-ID: <44D91351.2020702@intel.com>
Date: Tue, 08 Aug 2006 15:42:25 -0700
From: Auke Kok <auke-jan.h.kok@intel.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 3/9] e1000 driver conversion
References: <20060808193325.1396.58813.sendpatchset@lappy>	<20060808193355.1396.71047.sendpatchset@lappy>	<44D8F919.7000006@intel.com> <20060808.153210.52118365.davem@davemloft.net>
In-Reply-To: <20060808.153210.52118365.davem@davemloft.net>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: a.p.zijlstra@chello.nl, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, phillips@google.com, jesse.brandeburg@intel.com
List-ID: <linux-mm.kvack.org>

David Miller wrote:
> From: Auke Kok <auke-jan.h.kok@intel.com>
> Date: Tue, 08 Aug 2006 13:50:33 -0700
> 
>> can we really delete these??
> 
> netdev_alloc_skb() does it for you

yeah I didn't spot that patch #2 in that series introduces that code - my bad. 
Thanks.

Auke

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
