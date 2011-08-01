Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BFAE990015F
	for <linux-mm@kvack.org>; Mon,  1 Aug 2011 14:57:48 -0400 (EDT)
Date: Mon, 1 Aug 2011 11:57:45 -0700
From: Larry Bassel <lbassel@codeaurora.org>
Subject: Re: questions about memory hotplug
Message-ID: <20110801185745.GC3466@labbmf-linux.qualcomm.com>
References: <20110729221230.GA3466@labbmf-linux.qualcomm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110729221230.GA3466@labbmf-linux.qualcomm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Larry Bassel <lbassel@codeaurora.org>
Cc: linux-mm@kvack.org, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org

On 29 Jul 11 15:12, Larry Bassel wrote:
> 
> Would CONFIG_ARCH_POPULATES_NODE_MAP help here? Does anyone
> use this? It doesn't seem to be in any defconfig or Kconfig

I want to clarify this, I meant used on ARM -- I see it is being used
on other architectures (and that movablecore= and kernelcore=
require this config option).

> on 3.0 (or earlier versions I've looked at).
> 

Larry

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
