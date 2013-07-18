Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx145.postini.com [74.125.245.145])
	by kanga.kvack.org (Postfix) with SMTP id 47D306B0033
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 22:53:46 -0400 (EDT)
Date: Wed, 17 Jul 2013 22:04:14 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH 5/8] thp, mm: locking tail page is a bug
Message-ID: <20130718020414.GA1786@redhat.com>
References: <1373885274-25249-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1373885274-25249-6-git-send-email-kirill.shutemov@linux.intel.com>
 <20130717140953.7560e88e607f8f5df1b1fdd8@linux-foundation.org>
 <51E71E29.6030703@sr71.net>
 <alpine.LNX.2.00.1307171747210.23502@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1307171747210.23502@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dave Hansen <dave@sr71.net>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Wu Fengguang <fengguang.wu@intel.com>, Jan Kara <jack@suse.cz>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, Andi Kleen <ak@linux.intel.com>, Matthew Wilcox <willy@linux.intel.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Hillf Danton <dhillf@gmail.com>, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Jul 17, 2013 at 05:58:13PM -0700, Hugh Dickins wrote:
 > On Wed, 17 Jul 2013, Dave Hansen wrote:
 > > On 07/17/2013 02:09 PM, Andrew Morton wrote:
 > > > lock_page() is a pretty commonly called function, and I assume quite a
 > > > lot of people run with CONFIG_DEBUG_VM=y.
 > > > 
 > > > Is the overhead added by this patch really worthwhile?
 > > 
 > > I always thought of it as a developer-only thing.  I don't think any of
 > > the big distros turn it on by default.
 > 
 > That's how I think of it too (and the problem is often that too few mm
 > developers turn it on); but Dave Jones did confirm last November that
 > Fedora turns it on.
 > 
 > I believe Fedora turns it on to help us all, and wouldn't mind a mere
 > VM_BUG_ON(PageTail(page)) in __lock_page() if it's helpful to Kirill.
 > 
 > But if VM_BUG_ONs become expensive, I do think it's for Fedora to
 > turn off CONFIG_DEBUG_VM, rather than for mm developers to avoid it.

I'm ambivalent about whether we keep it on or off, we have no shortage
of bugs to fix already, though I think as mentioned above, very few people
actually enable it, so we're going to lose a lot of testing.

Another idea, perhaps is an extra config option for more expensive debug options ?

	Dave


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
