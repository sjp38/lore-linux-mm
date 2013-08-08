Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id D1D526B0031
	for <linux-mm@kvack.org>; Thu,  8 Aug 2013 10:09:54 -0400 (EDT)
Message-ID: <1375970993.2424.142.camel@joe-AO722>
Subject: Re: [PATCH part2 3/4] acpi: Remove "continue" in macro
 INVALID_TABLE().
From: Joe Perches <joe@perches.com>
Date: Thu, 08 Aug 2013 07:09:53 -0700
In-Reply-To: <52038C84.4080608@cn.fujitsu.com>
References: <1375938239-18769-1-git-send-email-tangchen@cn.fujitsu.com>
	 <1375938239-18769-4-git-send-email-tangchen@cn.fujitsu.com>
	 <1375939646.2424.132.camel@joe-AO722> <52038C84.4080608@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tang Chen <tangchen@cn.fujitsu.com>
Cc: robert.moore@intel.com, lv.zheng@intel.com, rjw@sisk.pl, lenb@kernel.org, tglx@linutronix.de, mingo@elte.hu, hpa@zytor.com, akpm@linux-foundation.org, tj@kernel.org, trenn@suse.de, yinghai@kernel.org, jiang.liu@huawei.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, izumi.taku@jp.fujitsu.com, mgorman@suse.de, minchan@kernel.org, mina86@mina86.com, gong.chen@linux.intel.com, vasilis.liaskovitis@profitbricks.com, lwoodman@redhat.com, riel@redhat.com, jweiner@redhat.com, prarit@redhat.com, zhangyanfei@cn.fujitsu.com, yanghy@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-acpi@vger.kernel.org

On Thu, 2013-08-08 at 20:18 +0800, Tang Chen wrote:
> Hi Joe,

Hello Tang.

> On 08/08/2013 01:27 PM, Joe Perches wrote:
> > On Thu, 2013-08-08 at 13:03 +0800, Tang Chen wrote:
> >
> >> Change it to the style like other macros:
> >>
> >>   #define INVALID_TABLE(x, path, name)                                    \
> >>           do { pr_err("ACPI OVERRIDE: " x " [%s%s]\n", path, name); } while (0)
> >
> > Single statement macros do _not_ need to use
> > 	"do { foo(); } while (0)"
> > and should be written as
> > 	"foo()"
> 
> OK, will remove the do {} while (0).
> 
> But I think we'd better keep the macro, or rename it to something
> more meaningful. At least we can use it to avoid adding "ACPI OVERRIDE:"
> prefix every time. Maybe this is why it is defined.

No, it's just silly.

If you really think that the #define is better, use
something like HW_ERR does and embed that #define
in the pr_err.

#define ACPI_OVERRIDE	"ACPI OVERRIDE: "

	pr_err(ACPI_OVERRIDE "Table smaller than ACPI header [%s%s]\n",
	       cpio_path, file.name);

It's only used a few times by a single file so
I think it's unnecessary.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
