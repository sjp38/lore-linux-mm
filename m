Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 713E96B007B
	for <linux-mm@kvack.org>; Mon, 21 Dec 2009 07:21:13 -0500 (EST)
Message-ID: <4B2F67CD.4060700@linux.intel.com>
Date: Mon, 21 Dec 2009 13:19:25 +0100
From: Andi Kleen <ak@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH ] memory-hotplug: create /sys/firmware/memmap entry for
 new memory(v3)
References: <DA586906BA1FFC4384FCFD6429ECE860302035FC@shzsmsx502.ccr.corp.intel.com>
In-Reply-To: <DA586906BA1FFC4384FCFD6429ECE860302035FC@shzsmsx502.ccr.corp.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: "Zheng, Shaohui" <shaohui.zheng@intel.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "y-goto@jp.fujitsu.com" <y-goto@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, "Wu, Fengguang" <fengguang.wu@intel.com>, akpm@osdl.org, stable@kernel.org
List-ID: <linux-mm.kvack.org>

Zheng, Shaohui wrote:
> Resend t he patch(v3) after the review by the mailing list, thanks so 
> much for Dave Hansen?s comments.

Both patches look good. IMHO they should both go into .33 and
are even stable candidates. Andrew, could you add them to your tree please?

-Andi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
