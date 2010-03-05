Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 819B96B0047
	for <linux-mm@kvack.org>; Fri,  5 Mar 2010 11:38:28 -0500 (EST)
References: <49b004811003041321g2567bac8yb73235be32a27e7c@mail.gmail.com> <20100305032106.GA12065@cmpxchg.org> <4B908FF3.5000303@kernel.org> <4B909327.2030702@kernel.org> <20100305125139.GA13726@cmpxchg.org>
Message-Id: <7EE97A35-A262-4040-BA2A-7F7A8347E8D5@kernel.org>
From: Yinghai <yinghai@kernel.org>
In-Reply-To: <20100305125139.GA13726@cmpxchg.org>
Content-Type: text/plain;
	charset=us-ascii;
	format=flowed;
	delsp=yes
Content-Transfer-Encoding: 7bit
Mime-Version: 1.0 (iPhone Mail 7D11)
Subject: Re: mmotm boot panic bootmem-avoid-dma32-zone-by-default.patch
Date: Fri, 5 Mar 2010 08:38:02 -0800
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Greg Thelen <gthelen@google.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>





On Mar 5, 2010, at 4:51 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:

>
> My patch just shows that with common machines: those with <=4G of  
> memory
> but you already broke uncommon machines without my patch, those with
> <=16M of memory.

Ok
Will fix it

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
