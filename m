Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id EF76F6B02C3
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 05:03:08 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id r203so25880150wmb.2
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 02:03:08 -0700 (PDT)
Received: from lhrrgout.huawei.com (lhrrgout.huawei.com. [194.213.3.17])
        by mx.google.com with ESMTPS id j22si7829352wre.322.2017.06.06.02.03.07
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Jun 2017 02:03:07 -0700 (PDT)
Subject: Re: [kernel-hardening] [PATCH 3/5] Protectable Memory Allocator -
 Debug interface
References: <20170605192216.21596-1-igor.stoppa@huawei.com>
 <20170605192216.21596-4-igor.stoppa@huawei.com>
 <CAG48ez1VMPLasTypDX5QnZnYprbCXfG9ZP9jQvPpS=HCpgvHvQ@mail.gmail.com>
From: Igor Stoppa <igor.stoppa@huawei.com>
Message-ID: <71a18a70-45c9-d75c-db47-3edf41b25a72@huawei.com>
Date: Tue, 6 Jun 2017 12:00:57 +0300
MIME-Version: 1.0
In-Reply-To: <CAG48ez1VMPLasTypDX5QnZnYprbCXfG9ZP9jQvPpS=HCpgvHvQ@mail.gmail.com>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: Kees Cook <keescook@chromium.org>, mhocko@kernel.org, jmorris@namei.org, penguin-kernel@i-love.sakura.ne.jp, Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>, casey@schaufler-ca.com, Christoph Hellwig <hch@infradead.org>, labbott@redhat.com, linux-mm@kvack.org, kernel list <linux-kernel@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>



On 05/06/17 23:24, Jann Horn wrote:
> On Mon, Jun 5, 2017 at 9:22 PM, Igor Stoppa <igor.stoppa@huawei.com> wrote:
>> Debugfs interface: it creates a file

[...]

> You should probably be using %pK to hide the kernel pointers.

ok, will do

---
igor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
