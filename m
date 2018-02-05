Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3D8FD6B0005
	for <linux-mm@kvack.org>; Mon,  5 Feb 2018 10:34:18 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id s9so28942289ioa.20
        for <linux-mm@kvack.org>; Mon, 05 Feb 2018 07:34:18 -0800 (PST)
Received: from resqmta-ch2-06v.sys.comcast.net (resqmta-ch2-06v.sys.comcast.net. [69.252.207.38])
        by mx.google.com with ESMTPS id f137si4271743ioe.114.2018.02.05.07.34.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Feb 2018 07:34:17 -0800 (PST)
Date: Mon, 5 Feb 2018 09:33:15 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [PATCH 3/6] struct page: add field for vm_struct
In-Reply-To: <a12afe9b-79cf-d5c1-3795-89fbf61c6c9d@huawei.com>
Message-ID: <alpine.DEB.2.20.1802050931190.10647@nuc-kabylake>
References: <20180130151446.24698-1-igor.stoppa@huawei.com> <20180130151446.24698-4-igor.stoppa@huawei.com> <alpine.DEB.2.20.1801311758340.21272@nuc-kabylake> <48fde114-d063-cfbf-e1b6-262411fcd963@huawei.com> <alpine.DEB.2.20.1802021240370.31548@nuc-kabylake>
 <a12afe9b-79cf-d5c1-3795-89fbf61c6c9d@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Igor Stoppa <igor.stoppa@huawei.com>
Cc: jglisse@redhat.com, keescook@chromium.org, mhocko@kernel.org, labbott@redhat.com, hch@infradead.org, willy@infradead.org, linux-security-module@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-hardening@lists.openwall.com

On Sat, 3 Feb 2018, Igor Stoppa wrote:

> - the property of the compound page will affect the property of all the
> pages in the compound, so when one is write protected, it can generate a
> lot of wasted memory, if there is too much slack (because of the order)
> With vmalloc, I can allocate any number of pages, minimizing the waste.

I thought the intend here is to create a pool where the whole pool becomes
RO?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
