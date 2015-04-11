Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f175.google.com (mail-qk0-f175.google.com [209.85.220.175])
	by kanga.kvack.org (Postfix) with ESMTP id 9FCFA6B0038
	for <linux-mm@kvack.org>; Sat, 11 Apr 2015 09:26:30 -0400 (EDT)
Received: by qkhg7 with SMTP id g7so79424300qkh.2
        for <linux-mm@kvack.org>; Sat, 11 Apr 2015 06:26:30 -0700 (PDT)
Received: from vena.lwn.net (tex.lwn.net. [70.33.254.29])
        by mx.google.com with ESMTPS id e75si1106276oic.7.2015.04.11.06.26.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sat, 11 Apr 2015 06:26:30 -0700 (PDT)
Date: Sat, 11 Apr 2015 15:26:16 +0200
From: Jonathan Corbet <corbet@lwn.net>
Subject: Re: [patch -mm] mm, doc: cleanup and clarify munmap behavior for
 hugetlb memory fix
Message-ID: <20150411152616.3e9d3157@lwn.net>
In-Reply-To: <alpine.DEB.2.10.1504091244501.11370@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1503261621570.20009@chino.kir.corp.google.com>
	<alpine.LSU.2.11.1503291801400.1052@eggly.anvils>
	<alpine.DEB.2.10.1504021536210.15536@chino.kir.corp.google.com>
	<alpine.DEB.2.10.1504021547330.15536@chino.kir.corp.google.com>
	<20150404113456.55468dc3@lwn.net>
	<alpine.DEB.2.10.1504091244501.11370@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Davide Libenzi <davidel@xmailserver.org>, Luiz Capitulino <lcapitulino@redhat.com>, Shuah Khan <shuahkh@osg.samsung.com>, Andrea Arcangeli <aarcange@redhat.com>, Joern Engel <joern@logfs.org>, Jianguo Wu <wujianguo@huawei.com>, Eric B Munson <emunson@akamai.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, linux-doc@vger.kernel.org

On Thu, 9 Apr 2015 12:46:09 -0700 (PDT)
David Rientjes <rientjes@google.com> wrote:

> It's been merged into that tree, but I would still appreciate your 
> ack!

Easy enough.

Acked-by: Jonathan Corbet <corbet@lwn.net>

jon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
