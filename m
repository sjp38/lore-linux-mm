Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 29AD26B0062
	for <linux-mm@kvack.org>; Mon, 10 Sep 2012 17:40:10 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so3407934pbb.14
        for <linux-mm@kvack.org>; Mon, 10 Sep 2012 14:40:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1209071558430.28027@chino.kir.corp.google.com>
References: <50484E2C.1060107@gmail.com>
	<alpine.DEB.2.00.1209071558430.28027@chino.kir.corp.google.com>
Date: Mon, 10 Sep 2012 14:40:09 -0700
Message-ID: <CA+8MBb+z27j7KNRhnVobgVU=ckSkSyuC7f=M7oNv=_2Oe5ovYA@mail.gmail.com>
Subject: Re: [PATCH RESEND]mm/ia64: fix a node distance bug
From: Tony Luck <tony.luck@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: wujianguo <wujianguo106@gmail.com>, akpm@linux-foundation.org, fenghua.yu@intel.com, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jiang.liu@huawei.com, guohanjun@huawei.com, qiuxishi@huawei.com, wujianguo@huawei.com, wency@cn.fujitsu.com

On Fri, Sep 7, 2012 at 3:58 PM, David Rientjes <rientjes@google.com> wrote:
> On Thu, 6 Sep 2012, wujianguo wrote:
>> Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
>> Signed-off-by: Jiang Liu <jiang.liu@huawei.com>
>
> Acked-by: David Rientjes <rientjes@google.com>

Applied (should show up in linux-next in the next day or two).

-Tony

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
