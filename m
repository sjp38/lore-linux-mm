Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f207.google.com (mail-pd0-f207.google.com [209.85.192.207])
	by kanga.kvack.org (Postfix) with ESMTP id 970126B0035
	for <linux-mm@kvack.org>; Tue, 31 Dec 2013 13:01:00 -0500 (EST)
Received: by mail-pd0-f207.google.com with SMTP id v10so139806pde.2
        for <linux-mm@kvack.org>; Tue, 31 Dec 2013 10:01:00 -0800 (PST)
Received: from out3-smtp.messagingengine.com (out3-smtp.messagingengine.com. [66.111.4.27])
        by mx.google.com with ESMTPS id jv8si33020539pbc.276.2013.12.30.01.54.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Dec 2013 01:54:44 -0800 (PST)
Message-ID: <52C142E0.8010003@iki.fi>
Date: Mon, 30 Dec 2013 11:54:40 +0200
From: Pekka Enberg <penberg@iki.fi>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/slub: fix accumulate per cpu partial cache objects
References: <1388137619-14741-1-git-send-email-liwanp@linux.vnet.ibm.com> <52BE2E74.1070107@huawei.com> <CAOJsxLFH5LGuF+vutPzB90EM9o376Jc99-rjY4qq18d1KQshhg@mail.gmail.com> <20131230010800.GA1623@hacker.(null)>
In-Reply-To: <20131230010800.GA1623@hacker.(null)>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>, Pekka Enberg <penberg@kernel.org>
Cc: Li Zefan <lizefan@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/30/2013 03:08 AM, Wanpeng Li wrote:
> Zefan's patch is good enough, mine doesn't need any more.

OK, thanks guys!

             Pekka

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
