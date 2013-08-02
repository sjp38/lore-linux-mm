Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 4CD126B0031
	for <linux-mm@kvack.org>; Fri,  2 Aug 2013 04:31:03 -0400 (EDT)
Message-ID: <51FB6DE6.6040200@cn.fujitsu.com>
Date: Fri, 02 Aug 2013 16:29:26 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 05/18] x86, acpi: Split acpi_boot_table_init() into
 two parts.
References: <1375340800-19332-1-git-send-email-tangchen@cn.fujitsu.com>  <1375340800-19332-6-git-send-email-tangchen@cn.fujitsu.com> <1375399931.10300.36.camel@misato.fc.hp.com> <1AE640813FDE7649BE1B193DEA596E8802437AC8@SHSMSX101.ccr.corp.intel.com> <51FB5948.6080802@cn.fujitsu.com> <1AE640813FDE7649BE1B193DEA596E8802437C47@SHSMSX101.ccr.corp.intel.com>
In-Reply-To: <1AE640813FDE7649BE1B193DEA596E8802437C47@SHSMSX101.ccr.corp.intel.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Zheng, Lv" <lv.zheng@intel.com>
Cc: Toshi Kani <toshi.kani@hp.com>, "rjw@sisk.pl" <rjw@sisk.pl>, "lenb@kernel.org" <lenb@kernel.org>, "tglx@linutronix.de" <tglx@linutronix.de>, "mingo@elte.hu" <mingo@elte.hu>, "hpa@zytor.com" <hpa@zytor.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "tj@kernel.org" <tj@kernel.org>, "trenn@suse.de" <trenn@suse.de>, "yinghai@kernel.org" <yinghai@kernel.org>, "jiang.liu@huawei.com" <jiang.liu@huawei.com>, "wency@cn.fujitsu.com" <wency@cn.fujitsu.com>, "laijs@cn.fujitsu.com" <laijs@cn.fujitsu.com>, "isimatu.yasuaki@jp.fujitsu.com" <isimatu.yasuaki@jp.fujitsu.com>, "izumi.taku@jp.fujitsu.com" <izumi.taku@jp.fujitsu.com>, "mgorman@suse.de" <mgorman@suse.de>, "minchan@kernel.org" <minchan@kernel.org>, "mina86@mina86.com" <mina86@mina86.com>, "gong.chen@linux.intel.com" <gong.chen@linux.intel.com>, "vasilis.liaskovitis@profitbricks.com" <vasilis.liaskovitis@profitbricks.com>, "lwoodman@redhat.com" <lwoodman@redhat.com>, "riel@redhat.com" <riel@redhat.com>, "jweiner@redhat.com" <jweiner@redhat.com>, "prarit@redhat.com" <prarit@redhat.com>, "zhangyanfei@cn.fujitsu.com" <zhangyanfei@cn.fujitsu.com>, "yanghy@cn.fujitsu.com" <yanghy@cn.fujitsu.com>, "x86@kernel.org" <x86@kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-acpi@vger.kernel.org" <linux-acpi@vger.kernel.org>, "Moore, Robert" <robert.moore@intel.com>

On 08/02/2013 04:23 PM, Zheng, Lv wrote:
......
>> According to what you've explained, what you didn=E2=80=99t want to be c=
alled
>> earlier is exactly "acpi initrd table override", please split only this =
logic to
>> the step 2 and leave the others remained.
>> I think you should write a function named as acpi=5Foverride=5Ftables() =
or
>> likewise in tbxface.c to be executed as the OSPM entry of the step 2.
>> Inside this function, acpi=5Ftb=5Ftable=5Foverride() should be called.
......

OK, I understand what you are suggesting now. It is reasonable.
I'll update the patch-set in the next version.

But today, I just rebased it to the latest kernel. I'll resend this
rebased v2 patch-set so that Tj and other guys can review it.

I'll include all of your comments in the v3 patch-set. Thank you very=20
much. :)

Thanks.
=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
