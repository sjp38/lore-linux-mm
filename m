Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l32LuEog028404
	for <linux-mm@kvack.org>; Mon, 2 Apr 2007 17:56:14 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l32LuE8Y044710
	for <linux-mm@kvack.org>; Mon, 2 Apr 2007 15:56:14 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l32LuDQX021890
	for <linux-mm@kvack.org>; Mon, 2 Apr 2007 15:56:14 -0600
Subject: Re: [PATCH 1/4] x86_64: Switch to SPARSE_VIRTUAL
From: Dave Hansen <hansendc@us.ibm.com>
In-Reply-To: <Pine.LNX.4.64.0704021422040.2272@schroedinger.engr.sgi.com>
References: <20070401071024.23757.4113.sendpatchset@schroedinger.engr.sgi.com>
	 <20070401071029.23757.78021.sendpatchset@schroedinger.engr.sgi.com>
	 <200704011246.52238.ak@suse.de>
	 <Pine.LNX.4.64.0704020832320.30394@schroedinger.engr.sgi.com>
	 <1175544797.22373.62.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0704021324480.31842@schroedinger.engr.sgi.com>
	 <1175548086.22373.99.camel@localhost.localdomain>
	 <Pine.LNX.4.64.0704021422040.2272@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 02 Apr 2007 14:56:08 -0700
Message-Id: <1175550968.22373.122.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andi Kleen <ak@suse.de>, linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, Martin Bligh <mbligh@google.com>, linux-mm@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-04-02 at 14:28 -0700, Christoph Lameter wrote:
> I do not care what its called as long as it 
> covers all the bases and is not a glaring performance regresssion (like 
> SPARSEMEM so far). 

I honestly don't doubt that there are regressions, somewhere.  Could you
elaborate, and perhaps actually show us some numbers on this?  Perhaps
instead of adding a completely new model, we can adapt the existing ones
somehow.

But, without some cold, hard, data, we mere mortals without the 1024-way
machines can only guess. ;)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
