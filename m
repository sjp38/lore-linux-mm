Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id A39AC6B0032
	for <linux-mm@kvack.org>; Mon, 12 Aug 2013 10:21:24 -0400 (EDT)
Received: by mail-ve0-f171.google.com with SMTP id pa12so5643515veb.2
        for <linux-mm@kvack.org>; Mon, 12 Aug 2013 07:21:23 -0700 (PDT)
Date: Mon, 12 Aug 2013 10:21:19 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH part2 3/4] acpi: Remove "continue" in macro
 INVALID_TABLE().
Message-ID: <20130812142119.GF15892@htj.dyndns.org>
References: <1375938239-18769-1-git-send-email-tangchen@cn.fujitsu.com>
 <1375938239-18769-4-git-send-email-tangchen@cn.fujitsu.com>
 <1375939646.2424.132.camel@joe-AO722>
 <52038C84.4080608@cn.fujitsu.com>
 <1375970993.2424.142.camel@joe-AO722>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1375970993.2424.142.camel@joe-AO722>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Thu, Aug 08, 2013 at 07:09:53AM -0700, Joe Perches wrote:
> If you really think that the #define is better, use
> something like HW_ERR does and embed that #define
> in the pr_err.
> 
> #define ACPI_OVERRIDE	"ACPI OVERRIDE: "
> 
> 	pr_err(ACPI_OVERRIDE "Table smaller than ACPI header [%s%s]\n",
> 	       cpio_path, file.name);
> 
> It's only used a few times by a single file so
> I think it's unnecessary.

I agree with Joe here.  Just doing normal pr_err() should be enough.
You can use pr_fmt() to add headers but given that we aren't talking
about huge number of printks, that probably is an overkill too.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
