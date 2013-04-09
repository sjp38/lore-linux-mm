Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 529DA6B0006
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 04:18:34 -0400 (EDT)
Message-ID: <5163CF82.8040806@cn.fujitsu.com>
Date: Tue, 09 Apr 2013 16:21:22 +0800
From: Tang Chen <tangchen@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/11] Introduce movablemem_map=acpi boot option.
References: <1365154801-473-1-git-send-email-tangchen@cn.fujitsu.com> <5163A3BF.3030900@jp.fujitsu.com>
In-Reply-To: <5163A3BF.3030900@jp.fujitsu.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-2022-JP
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: rob@landley.net, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, yinghai@kernel.org, akpm@linux-foundation.org, wency@cn.fujitsu.com, trenn@suse.de, liwanp@linux.vnet.ibm.com, mgorman@suse.de, walken@google.com, riel@redhat.com, khlebnikov@openvz.org, tj@kernel.org, minchan@kernel.org, m.szyprowski@samsung.com, mina86@mina86.com, laijs@cn.fujitsu.com, linfeng@cn.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, jiang.liu@huawei.com, guz.fnst@cn.fujitsu.com, x86@kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 04/09/2013 01:14 PM, Yasuaki Ishimatsu wrote:
> Hi Tang,
> 
> The patch works well on my x86_64 box.
> I confirmed that hotpluggable node is allocated as Movable Zone.
> So feel free to add:
> 
> Tested by: Yasuaki Ishimatsu<isimatu.yasuaki@jp.fujitsu.com>
> 
> Nitpick below.

Thanks for testing. Will fix the whitespace error and resend the
patch-set soon. :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
