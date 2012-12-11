Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id DA24D6B006C
	for <linux-mm@kvack.org>; Tue, 11 Dec 2012 08:12:39 -0500 (EST)
Date: Tue, 11 Dec 2012 14:12:37 +0100
From: Borislav Petkov <bp@alien8.de>
Subject: Re: [PATCH V3 1/2] MCE: fix an error of mce_bad_pages statistics
Message-ID: <20121211131236.GA4303@liondog.tnic>
References: <50C72493.3080009@huawei.com>
 <20121211124238.GA9959@hacker.(null)>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20121211124238.GA9959@hacker.(null)>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Xishi Qiu <qiuxishi@huawei.com>, WuJianguo <wujianguo@huawei.com>, Liujiang <jiang.liu@huawei.com>, Simon Jeons <simon.jeons@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Fengguang Wu <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Dec 11, 2012 at 08:42:39PM +0800, Wanpeng Li wrote:
> Futhermore, Andrew didn't like a variable called "mce_bad_pages".
>
> - Why do we have a variable called "mce_bad_pages"? MCE is an x86
> concept, and this code is in mm/. Lights are flashing, bells are
> ringing and a loudspeaker is blaring "layering violation" at us!

Yes, this should simply be called num_poisoned_pages because this is
what this thing counts.

-- 
Regards/Gruss,
    Boris.

Sent from a fat crate under my desk. Formatting is fine.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
