Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id 3B10B6B0038
	for <linux-mm@kvack.org>; Tue,  7 Jul 2015 17:51:44 -0400 (EDT)
Received: by igrv9 with SMTP id v9so186690455igr.1
        for <linux-mm@kvack.org>; Tue, 07 Jul 2015 14:51:44 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id bx19si17962741igb.63.2015.07.07.14.51.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Jul 2015 14:51:43 -0700 (PDT)
Date: Tue, 7 Jul 2015 14:51:42 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH V3 5/5] selftests: vm: Add tests for lock on fault
Message-Id: <20150707145142.ccc0b63eb48a5e5dd307accf@linux-foundation.org>
In-Reply-To: <1436288623-13007-6-git-send-email-emunson@akamai.com>
References: <1436288623-13007-1-git-send-email-emunson@akamai.com>
	<1436288623-13007-6-git-send-email-emunson@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Shuah Khan <shuahkh@osg.samsung.com>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org

On Tue,  7 Jul 2015 13:03:43 -0400 Eric B Munson <emunson@akamai.com> wrote:

> Test the mmap() flag, and the mlockall() flag.  These tests ensure that
> pages are not faulted in until they are accessed, that the pages are
> unevictable once faulted in, and that VMA splitting and merging works
> with the new VM flag.  The second test ensures that mlock limits are
> respected.  Note that the limit test needs to be run a normal user.

So we don't have tests for the new syscalls?

I have renumbered those syscalls (added 1) because of sys_userfaultfd.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
