Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 3A5CE6B006E
	for <linux-mm@kvack.org>; Thu, 17 Nov 2011 12:57:55 -0500 (EST)
Date: Thu, 17 Nov 2011 17:57:37 +0000
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RFC PATCH] kmemleak: Add support for memory hotplug
Message-ID: <20111117175737.GA23875@arm.com>
References: <1321400949-1852-1-git-send-email-lauraa@codeaurora.org>
 <1321400949-1852-2-git-send-email-lauraa@codeaurora.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1321400949-1852-2-git-send-email-lauraa@codeaurora.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <lauraa@codeaurora.org>
Cc: "mingo@elte.hu" <mingo@elte.hu>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-msm@vger.kernel.org" <linux-arm-msm@vger.kernel.org>

On Tue, Nov 15, 2011 at 11:49:09PM +0000, Laura Abbott wrote:
> Ensure that memory hotplug can co-exist with kmemleak
> by taking the hotplug lock before scanning the memory
> banks.
> 
> Signed-off-by: Laura Abbott <lauraa@codeaurora.org>

Thanks, the patch looks fine to me. I'll add it to my kmemleak branch
for the next merging window.

-- 
Catalin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
