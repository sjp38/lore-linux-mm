Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0869B6B0069
	for <linux-mm@kvack.org>; Wed,  4 Jan 2017 18:00:32 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id a190so1344910995pgc.0
        for <linux-mm@kvack.org>; Wed, 04 Jan 2017 15:00:32 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id p20si57306999pli.180.2017.01.04.15.00.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 04 Jan 2017 15:00:31 -0800 (PST)
Date: Wed, 4 Jan 2017 15:01:46 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 07/42] userfaultfd: non-cooperative: report all
 available features to userland
Message-Id: <20170104150146.4c26286146460eafbdc77cb3@linux-foundation.org>
In-Reply-To: <20161216144821.5183-8-aarcange@redhat.com>
References: <20161216144821.5183-1-aarcange@redhat.com>
	<20161216144821.5183-8-aarcange@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org, Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

On Fri, 16 Dec 2016 15:47:46 +0100 Andrea Arcangeli <aarcange@redhat.com> wrote:

> This will allow userland to probe all features available in the
> kernel. It will however only enable the requested features in the
> open userfaultfd context.

Is the user-facing documentation updated somewhere?  I guess that's
Documentation/vm/userfaultfd.txt.  Does a manpage exist yet?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
