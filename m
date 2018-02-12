Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 813496B0030
	for <linux-mm@kvack.org>; Mon, 12 Feb 2018 10:42:11 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id x188so2513711wmg.2
        for <linux-mm@kvack.org>; Mon, 12 Feb 2018 07:42:11 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id r9si3784668wme.262.2018.02.12.07.42.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Feb 2018 07:42:10 -0800 (PST)
Subject: Re: [PATCH 4/6] Protectable Memory
References: <20180211031920.3424-1-igor.stoppa@huawei.com>
 <20180211031920.3424-5-igor.stoppa@huawei.com>
 <20180211123743.GC13931@rapoport-lnx>
 <e7ea02b4-3d43-9543-3d14-61c27e155042@huawei.com>
 <20180212114310.GD20737@rapoport-lnx> <20180212125347.GE20737@rapoport-lnx>
 <68edadf0-2b23-eaeb-17de-884032f0b906@huawei.com>
 <20180212153156.GF20737@rapoport-lnx>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <f5c08b12-a274-f2db-5cf2-8b774489c425@huawei.com>
Date: Mon, 12 Feb 2018 17:41:52 +0200
MIME-Version: 1.0
In-Reply-To: <20180212153156.GF20737@rapoport-lnx>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: willy@infradead.org, rdunlap@infradead.org, corbet@lwn.net, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, jglisse@redhat.com, hch@infradead.org, cl@linux.com, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On 12/02/18 17:31, Mike Rapoport wrote:

[...]

> Seems that kernel-doc does not consider () as a valid match for the
> identifier :)
>  
> Can you please check with the below patch?

yes, it works now, than you!

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
