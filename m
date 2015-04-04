Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com [209.85.214.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3C5CC6B0038
	for <linux-mm@kvack.org>; Sat,  4 Apr 2015 05:35:06 -0400 (EDT)
Received: by obvd1 with SMTP id d1so197220631obv.0
        for <linux-mm@kvack.org>; Sat, 04 Apr 2015 02:35:06 -0700 (PDT)
Received: from vena.lwn.net (tex.lwn.net. [70.33.254.29])
        by mx.google.com with ESMTPS id b6si7518678oby.16.2015.04.04.02.35.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 04 Apr 2015 02:35:05 -0700 (PDT)
Date: Sat, 4 Apr 2015 11:34:56 +0200
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [patch -mm] mm, doc: cleanup and clarify munmap behavior for
 hugetlb memory fix
Message-ID: <20150404113456.55468dc3@lwn.net>
In-Reply-To: <alpine.DEB.2.10.1504021547330.15536@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1503261621570.20009@chino.kir.corp.google.com>
	<alpine.LSU.2.11.1503291801400.1052@eggly.anvils>
	<alpine.DEB.2.10.1504021536210.15536@chino.kir.corp.google.com>
	<alpine.DEB.2.10.1504021547330.15536@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Davide Libenzi <davidel@xmailserver.org>, Luiz Capitulino <lcapitulino@redhat.com>, Shuah Khan <shuahkh@osg.samsung.com>, Andrea Arcangeli <aarcange@redhat.com>, Joern Engel <joern@logfs.org>, Jianguo Wu <wujianguo@huawei.com>, Eric B Munson <emunson@akamai.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-doc@vger.kernel.org

On Thu, 2 Apr 2015 15:50:15 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> Don't only specify munmap(2) behavior with respect the hugetlb memory, all 
> other syscalls get naturally aligned to the native page size of the 
> processor.  Rather, pick out munmap(2) as a specific example.

So I was going to apply this to the docs tree, but it doesn't even come
close.  What tree was this patch generated against?

Thanks,

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
