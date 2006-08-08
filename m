Date: Tue, 08 Aug 2006 15:32:10 -0700 (PDT)
Message-Id: <20060808.153210.52118365.davem@davemloft.net>
Subject: Re: [RFC][PATCH 3/9] e1000 driver conversion
From: David Miller <davem@davemloft.net>
In-Reply-To: <44D8F919.7000006@intel.com>
References: <20060808193325.1396.58813.sendpatchset@lappy>
	<20060808193355.1396.71047.sendpatchset@lappy>
	<44D8F919.7000006@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Auke Kok <auke-jan.h.kok@intel.com>
Date: Tue, 08 Aug 2006 13:50:33 -0700
Return-Path: <owner-linux-mm@kvack.org>
To: auke-jan.h.kok@intel.com
Cc: a.p.zijlstra@chello.nl, linux-mm@kvack.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org, phillips@google.com, jesse.brandeburg@intel.com
List-ID: <linux-mm.kvack.org>

> can we really delete these??

netdev_alloc_skb() does it for you

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
