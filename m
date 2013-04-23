Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 101D26B0038
	for <linux-mm@kvack.org>; Tue, 23 Apr 2013 12:06:55 -0400 (EDT)
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [Bug fix PATCH v2] numa, cpu hotplug: Change links of CPU and node when changing node number by onlining CPU
References: <5170D4CB.20900@jp.fujitsu.com>
	<20130422153541.04ba682f13910cfede0d2ff7@linux-foundation.org>
Date: Tue, 23 Apr 2013 09:06:55 -0700
In-Reply-To: <20130422153541.04ba682f13910cfede0d2ff7@linux-foundation.org>
	(Andrew Morton's message of "Mon, 22 Apr 2013 15:35:41 -0700")
Message-ID: <m2y5c9ut7k.fsf@firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, kosaki.motohiro@gmail.com, mingo@kernel.org, hpa@zytor.com, srivatsa.bhat@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org

Andrew Morton <akpm@linux-foundation.org> writes:
>
> Would it not be better to fix this by assigning those CPUs to their real,
> memoryless node right at the initial boot?  Or is there something in
> the kernel which makes cpus-on-a-memoryless-node not work correctly?

I probably added this originally. The original reason was that long
ago the VM was broken with memory less nodes. These days it is likely
obsolete.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
