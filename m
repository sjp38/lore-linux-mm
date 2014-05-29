Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f48.google.com (mail-qg0-f48.google.com [209.85.192.48])
	by kanga.kvack.org (Postfix) with ESMTP id 400786B003C
	for <linux-mm@kvack.org>; Thu, 29 May 2014 03:58:50 -0400 (EDT)
Received: by mail-qg0-f48.google.com with SMTP id i50so21090662qgf.7
        for <linux-mm@kvack.org>; Thu, 29 May 2014 00:58:49 -0700 (PDT)
Received: from cam-admin0.cambridge.arm.com (cam-admin0.cambridge.arm.com. [217.140.96.50])
        by mx.google.com with ESMTP id e10si227238qcd.14.2014.05.29.00.58.48
        for <linux-mm@kvack.org>;
        Thu, 29 May 2014 00:58:49 -0700 (PDT)
Date: Thu, 29 May 2014 08:58:38 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v3] ARM: mm: support big-endian page tables
Message-ID: <20140529075837.GA29812@arm.com>
References: <534F9F79.9050503@huawei.com>
 <87ob00wau2.fsf@approximate.cambridge.arm.com>
 <20140423132033.GE5649@arm.com>
 <53587C48.8080103@huawei.com>
 <5386A799.7040403@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5386A799.7040403@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jianguo Wu <wujianguo@huawei.com>
Cc: "linux@arm.linux.org.uk" <linux@arm.linux.org.uk>, Wang Nan <wangnan0@huawei.com>, Marc Zyngier <Marc.Zyngier@arm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Li Zefan <lizefan@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Ben Dooks <ben.dooks@codethink.co.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, qiuxishi <qiuxishi@huawei.com>

On Thu, May 29, 2014 at 04:20:57AM +0100, Jianguo Wu wrote:
> Hi Russell,
> Could you please merge this to mainline? Thanks!

Give him a chance, it's not the merge window yet ;) I can see it queued in
his for-next branch.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
