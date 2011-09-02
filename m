Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id E28E76B0176
	for <linux-mm@kvack.org>; Fri,  2 Sep 2011 07:36:58 -0400 (EDT)
Message-ID: <4E60C067.4010600@citrix.com>
Date: Fri, 2 Sep 2011 12:39:19 +0100
From: David Vrabel <david.vrabel@citrix.com>
MIME-Version: 1.0
Subject: Re: [Revert] Re: [PATCH] mm: sync vmalloc address space page tables
 in alloc_vm_area()
References: <1314877863-21977-1-git-send-email-david.vrabel@citrix.com>	<20110901161134.GA8979@dumpdata.com>	<4E5FED1A.1000300@goop.org> <20110901141754.76cef93b.akpm@linux-foundation.org>
In-Reply-To: <20110901141754.76cef93b.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "namhyung@gmail.com" <namhyung@gmail.com>, "rientjes@google.com" <rientjes@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>, "paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>

On 01/09/11 22:17, Andrew Morton wrote:
> On Thu, 01 Sep 2011 13:37:46 -0700
> Jeremy Fitzhardinge <jeremy@goop.org> wrote:
> 
>> On 09/01/2011 09:11 AM, Konrad Rzeszutek Wilk wrote:
>>> On Thu, Sep 01, 2011 at 12:51:03PM +0100, David Vrabel wrote:
>>>> From: David Vrabel <david.vrabel@citrix.com>
>>> Andrew,
>>>
>>> I was wondering if you would be Ok with this patch for 3.1.
>>>
>>> It is a revert (I can prepare a proper revert if you would like
>>> that instead of this patch).
> 
> David's patch looks better than a straight reversion.
> 
> Problem is, I can't find David's original email anywhere.  Someone's
> been playing games with To: headers?

Sorry, I should have Cc'd linux-kernel and others on the original patch.
