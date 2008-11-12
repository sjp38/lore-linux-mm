Date: Tue, 11 Nov 2008 21:10:45 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 2/4] Add replace_page(), change the mapping of pte from
 one page into another
In-Reply-To: <20081112022701.GT10818@random.random>
Message-ID: <Pine.LNX.4.64.0811112109390.10501@quilx.com>
References: <1226409701-14831-1-git-send-email-ieidus@redhat.com>
 <1226409701-14831-2-git-send-email-ieidus@redhat.com>
 <1226409701-14831-3-git-send-email-ieidus@redhat.com>
 <20081111114555.eb808843.akpm@linux-foundation.org> <20081111210655.GG10818@random.random>
 <Pine.LNX.4.64.0811111522150.27767@quilx.com> <20081111221753.GK10818@random.random>
 <Pine.LNX.4.64.0811111626520.29222@quilx.com> <20081111231722.GR10818@random.random>
 <Pine.LNX.4.64.0811111823030.31625@quilx.com> <20081112022701.GT10818@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, chrisw@redhat.com, avi@redhat.com, izike@qumranet.com
List-ID: <linux-mm.kvack.org>

On Wed, 12 Nov 2008, Andrea Arcangeli wrote:

> So are you checking if there's an unresolved reference only in the
> very place I just quoted in the previous email? If answer is yes: what
> should prevent get_user_pages from running in parallel from another
> thread? get_user_pages will trigger a minor fault and get the elevated
> reference just after you read page_count. To you it looks like there
> is no o_direct in progress when you proceed to the core of migration
> code, but in effect o_direct just started a moment after you read the
> page count.

get_user_pages() cannot get to it since the pagetables have already been
modified. If get_user_pages runs then the fault handling will occur
which will block the thread until migration is complete.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
