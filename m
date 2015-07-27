Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 41BCA6B0038
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 02:31:49 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so100842653wib.0
        for <linux-mm@kvack.org>; Sun, 26 Jul 2015 23:31:48 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id p11si29057854wjw.192.2015.07.26.23.31.47
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 26 Jul 2015 23:31:47 -0700 (PDT)
Received: by wicgb10 with SMTP id gb10so97036066wic.1
        for <linux-mm@kvack.org>; Sun, 26 Jul 2015 23:31:47 -0700 (PDT)
Date: Mon, 27 Jul 2015 09:31:43 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH V5 1/7] mm: mlock: Refactor mlock, munlock, and
 munlockall code
Message-ID: <20150727063143.GA11657@node.dhcp.inet.fi>
References: <1437773325-8623-1-git-send-email-emunson@akamai.com>
 <1437773325-8623-2-git-send-email-emunson@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437773325-8623-2-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jul 24, 2015 at 05:28:39PM -0400, Eric B Munson wrote:
> Extending the mlock system call is very difficult because it currently
> does not take a flags argument.  A later patch in this set will extend
> mlock to support a middle ground between pages that are locked and
> faulted in immediately and unlocked pages.  To pave the way for the new
> system call, the code needs some reorganization so that all the actual
> entry point handles is checking input and translating to VMA flags.
> 
> Signed-off-by: Eric B Munson <emunson@akamai.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
