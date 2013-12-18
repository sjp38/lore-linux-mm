Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f174.google.com (mail-pd0-f174.google.com [209.85.192.174])
	by kanga.kvack.org (Postfix) with ESMTP id 5BB906B0035
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 20:38:48 -0500 (EST)
Received: by mail-pd0-f174.google.com with SMTP id y13so7505518pdi.19
        for <linux-mm@kvack.org>; Tue, 17 Dec 2013 17:38:48 -0800 (PST)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id gn4si12986998pbc.226.2013.12.17.17.38.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 17 Dec 2013 17:38:47 -0800 (PST)
Message-ID: <52B0F9CB.5010508@huawei.com>
Date: Wed, 18 Dec 2013 09:26:35 +0800
From: Li Zefan <lizefan@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 0/5] VFS: Directory level cache cleaning
References: <cover.1387205337.git.liwang@ubuntukylin.com> <CAM_iQpUSX1yX9SMvUnbwZ7UkaBMUheOEiZNaSb4m8gWBQzzGDQ@mail.gmail.com> <52AFC020.10403@ubuntukylin.com> <20131217035847.GA10392@parisc-linux.org> <52AFFBE3.8020507@ubuntukylin.com> <52B01594.80001@huawei.com> <52B019F5.7020505@ubuntukylin.com>
In-Reply-To: <52B019F5.7020505@ubuntukylin.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Wang <liwang@ubuntukylin.com>
Cc: Matthew Wilcox <matthew@wil.cx>, Cong Wang <xiyou.wangcong@gmail.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Sage Weil <sage@inktank.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Yunchuan Wen <yunchuanwen@ubuntukylin.com>

On 2013/12/17 17:31, Li Wang wrote:
> This extension is just add-on extension. The original debugging
> capability is still there, and more flexible debugging is now allowed.
> 

but you intent is to let applications use this interface for
non-debugging purpose.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
