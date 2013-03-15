Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id A898D6B0027
	for <linux-mm@kvack.org>; Fri, 15 Mar 2013 09:32:09 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <CAJd=RBCU=aaH-Osq-3gXSHZsropU=7yPU-ay7zvWoKsdoBOn6g@mail.gmail.com>
References: <1363283435-7666-1-git-send-email-kirill.shutemov@linux.intel.com>
 <CAJd=RBCU=aaH-Osq-3gXSHZsropU=7yPU-ay7zvWoKsdoBOn6g@mail.gmail.com>
Subject: Re: [PATCHv2, RFC 00/30] Transparent huge page cache
Content-Transfer-Encoding: 7bit
Message-Id: <20130315133348.8FA3CE0085@blue.fi.intel.com>
Date: Fri, 15 Mar 2013 15:33:48 +0200 (EET)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Al Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <matthew.r.wilcox@intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

Hillf Danton wrote:
> On Fri, Mar 15, 2013 at 1:50 AM, Kirill A. Shutemov
> <kirill.shutemov@linux.intel.com> wrote:
> >
> > Here's the second version of the patchset.
> >
> > The intend of the work is get code ready to enable transparent huge page
> > cache for the most simple fs -- ramfs.
> >
> Where is your git tree including THP cache?

Here: git://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git

Tag thp/pagecache/v2 represents the patcheset.
Branch thp/pagecache has fixed according to your feedback.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
