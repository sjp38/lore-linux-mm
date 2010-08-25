Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C56F66B0208
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 17:36:26 -0400 (EDT)
Message-ID: <4C758CC4.8000908@zytor.com>
Date: Wed, 25 Aug 2010 14:36:04 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [BUGFIX][PATCH 1/2] x86, mem: separate x86_64 vmalloc_sync_all()
 into separate functions
References: <4C6E4ECD.1090607@linux.intel.com> <87r5hni19y.fsf@basil.nowhere.org> <4C756BA0.2090700@zytor.com>
In-Reply-To: <4C756BA0.2090700@zytor.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Haicheng Li <haicheng.li@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "ak@linux.intel.com" <ak@linux.intel.com>, Wu Fengguang <fengguang.wu@intel.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On 08/25/2010 12:14 PM, H. Peter Anvin wrote:
> 
> The patches are mangled so they don't apply even with patch -l --
> Haicheng, could you send me another copy, as an attachment if necessary?
> 

Never mind, I fixed them up by hand.

	-hpa

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
