Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E87686B0005
	for <linux-mm@kvack.org>; Fri,  2 Feb 2018 11:46:13 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id w101so14852544wrc.18
        for <linux-mm@kvack.org>; Fri, 02 Feb 2018 08:46:13 -0800 (PST)
Received: from huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id c92si624754edd.246.2018.02.02.08.46.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Feb 2018 08:46:12 -0800 (PST)
Subject: Re: [PATCH 3/6] struct page: add field for vm_struct
References: <20180130151446.24698-1-igor.stoppa@huawei.com>
 <20180130151446.24698-4-igor.stoppa@huawei.com>
 <alpine.DEB.2.20.1801311758340.21272@nuc-kabylake>
 <48fde114-d063-cfbf-e1b6-262411fcd963@huawei.com>
 <CAGXu5jKKeJL13dcaY=fDJ8AiOXDP5MhQTqDYDOt3a374CFA1HQ@mail.gmail.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <938d71a3-323a-1af3-3815-cd5e1b9813c9@huawei.com>
Date: Fri, 2 Feb 2018 18:01:27 +0200
MIME-Version: 1.0
In-Reply-To: <CAGXu5jKKeJL13dcaY=fDJ8AiOXDP5MhQTqDYDOt3a374CFA1HQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Christopher Lameter <cl@linux.com>, jglisse@redhat.com, Michal Hocko <mhocko@kernel.org>, Laura Abbott <labbott@redhat.com>, Christoph Hellwig <hch@infradead.org>, Matthew Wilcox <willy@infradead.org>, linux-security-module <linux-security-module@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kernel-hardening@lists.openwall.com



On 01/02/18 23:11, Kees Cook wrote:

> IIUC, he means PageHead(), which is also hard to grep for, since it is
> a constructed name, via Page##uname in include/linux/page-flags.h:
> 
> __PAGEFLAG(Head, head, PF_ANY) CLEARPAGEFLAG(Head, head, PF_ANY)

Thank you, I'll try to provide a meaningful reply soon, but I'll be AFK
during most of next 2 weeks, so it might be delayed :-(

--
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
