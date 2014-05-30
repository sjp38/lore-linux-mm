Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 623716B0038
	for <linux-mm@kvack.org>; Thu, 29 May 2014 20:16:27 -0400 (EDT)
Received: by mail-wi0-f169.google.com with SMTP id hi2so277266wib.0
        for <linux-mm@kvack.org>; Thu, 29 May 2014 17:16:26 -0700 (PDT)
Received: from pandora.arm.linux.org.uk (pandora.arm.linux.org.uk. [2001:4d48:ad52:3201:214:fdff:fe10:1be6])
        by mx.google.com with ESMTPS id z15si967252wia.47.2014.05.29.17.16.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 29 May 2014 17:16:25 -0700 (PDT)
Date: Fri, 30 May 2014 01:13:54 +0100
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH v3] ARM: mm: support big-endian page tables
Message-ID: <20140530001354.GN3693@n2100.arm.linux.org.uk>
References: <534F9F79.9050503@huawei.com> <87ob00wau2.fsf@approximate.cambridge.arm.com> <20140423132033.GE5649@arm.com> <53587C48.8080103@huawei.com> <5386A799.7040403@huawei.com> <20140529075837.GA29812@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140529075837.GA29812@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Jianguo Wu <wujianguo@huawei.com>, Wang Nan <wangnan0@huawei.com>, Marc Zyngier <Marc.Zyngier@arm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Li Zefan <lizefan@huawei.com>, Catalin Marinas <Catalin.Marinas@arm.com>, Ben Dooks <ben.dooks@codethink.co.uk>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, qiuxishi <qiuxishi@huawei.com>

On Thu, May 29, 2014 at 08:58:38AM +0100, Will Deacon wrote:
> On Thu, May 29, 2014 at 04:20:57AM +0100, Jianguo Wu wrote:
> > Hi Russell,
> > Could you please merge this to mainline? Thanks!
> 
> Give him a chance, it's not the merge window yet ;) I can see it queued in
> his for-next branch.

It's not like it's something that has ever worked in the past - so
it's really a new feature rather than a bug fix, even through we've
been growing BE support in other areas.

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
