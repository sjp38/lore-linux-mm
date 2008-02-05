Subject: Re: [PATCH] badness() dramatically overcounts memory
From: Jeff Davis <linux@j-davis.com>
In-Reply-To: <47A7E282.1080902@linux.vnet.ibm.com>
References: <1202182480.24634.22.camel@dogma.ljc.laika.com>
	 <47A7E282.1080902@linux.vnet.ibm.com>
Content-Type: text/plain
Date: Tue, 05 Feb 2008 15:02:41 -0800
Message-Id: <1202252561.24634.64.camel@dogma.ljc.laika.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2008-02-05 at 09:43 +0530, Balbir Singh wrote:
> 1. grep on the kernel source tells me that shared_vm is incremented only in
>    vm_stat_account(), which is a NO-OP if CONFIG_PROC_FS is not defined.

I see, thanks for pointing that out. Is there another way do you think?
Would the penalty be to high to enable vm_stat_account when
CONFIG_PROC_FS is not defined?

Or perhaps my patch would only have an effect when CONFIG_PROC_FS is set
(which is default)?

> 2. How have you tested these patches? One way to do it would be to use the
>    memory controller and set a small limit on the control group. A memory
>    intensive application will soon see an OOM.

I have done a quick test a while back when I first wrote the patch. I
will test more thoroughly now.

> The interesting thing is the use of total_vm and not the RSS which is used as
> the basis by the OOM killer. I need to read/understand the code a bit more.

RSS makes more sense to me as well.

To me, it makes no sense to count shared memory, because killing a
process doesn't free the shared memory.

Regards,
	Jeff Davis

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
