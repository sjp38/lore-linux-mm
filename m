Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id CA5536B0033
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 18:44:02 -0400 (EDT)
Message-ID: <51E71E29.6030703@sr71.net>
Date: Wed, 17 Jul 2013 15:43:53 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [PATCH 5/8] thp, mm: locking tail page is a bug
References: <1373885274-25249-1-git-send-email-kirill.shutemov@linux.intel.com> <1373885274-25249-6-git-send-email-kirill.shutemov@linux.intel.com> <20130717140953.7560e88e607f8f5df1b1fdd8@linux-foundation.org>
In-Reply-To: <20130717140953.7560e88e607f8f5df1b1fdd8@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 07/17/2013 02:09 PM, Andrew Morton wrote:
> lock_page() is a pretty commonly called function, and I assume quite a
> lot of people run with CONFIG_DEBUG_VM=y.
> 
> Is the overhead added by this patch really worthwhile?

I always thought of it as a developer-only thing.  I don't think any of
the big distros turn it on by default.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
