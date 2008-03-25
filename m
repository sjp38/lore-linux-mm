Date: Tue, 25 Mar 2008 12:25:04 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: RE: [11/14] vcompound: Fallbacks for order 1 stack allocations on
 IA64 and x86
In-Reply-To: <1FE6DD409037234FAB833C420AA843ECE9DDFA@orsmsx424.amr.corp.intel.com>
Message-ID: <Pine.LNX.4.64.0803251223470.17521@schroedinger.engr.sgi.com>
References: <20080321061726.782068299@sgi.com> <20080321.002502.223136918.davem@davemloft.net>
 <Pine.LNX.4.64.0803211037140.18671@schroedinger.engr.sgi.com>
 <20080321.145712.198736315.davem@davemloft.net>
 <Pine.LNX.4.64.0803241121090.3002@schroedinger.engr.sgi.com>
 <1FE6DD409037234FAB833C420AA843ECE5B84D@orsmsx424.amr.corp.intel.com>
 <Pine.LNX.4.64.0803251036410.15870@schroedinger.engr.sgi.com>
 <1FE6DD409037234FAB833C420AA843ECE9DDFA@orsmsx424.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Luck, Tony" <tony.luck@intel.com>
Cc: David Miller <davem@davemloft.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 25 Mar 2008, Luck, Tony wrote:

> dtr[1] : maps an area of region 7 that spans kernel stack
>          page size is kernel granule size (default 16M).
>          This mapping needs to be reset on a context switch
>          where we move to a stack in a different granule.

Interesting.... Never realized we were doing these tricks with DTR.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
