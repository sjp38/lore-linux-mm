Date: Wed, 12 Nov 2008 14:27:42 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 2/4] Add replace_page(), change the mapping of pte from
 one page into another
In-Reply-To: <20081112173258.GX10818@random.random>
Message-ID: <Pine.LNX.4.64.0811121412130.31606@quilx.com>
References: <1226409701-14831-3-git-send-email-ieidus@redhat.com>
 <20081111114555.eb808843.akpm@linux-foundation.org> <20081111210655.GG10818@random.random>
 <Pine.LNX.4.64.0811111522150.27767@quilx.com> <20081111221753.GK10818@random.random>
 <Pine.LNX.4.64.0811111626520.29222@quilx.com> <20081111231722.GR10818@random.random>
 <Pine.LNX.4.64.0811111823030.31625@quilx.com> <20081112022701.GT10818@random.random>
 <Pine.LNX.4.64.0811112109390.10501@quilx.com> <20081112173258.GX10818@random.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, chrisw@redhat.com, avi@redhat.com, izike@qumranet.com
List-ID: <linux-mm.kvack.org>

On Wed, 12 Nov 2008, Andrea Arcangeli wrote:

> On Tue, Nov 11, 2008 at 09:10:45PM -0600, Christoph Lameter wrote:
> > get_user_pages() cannot get to it since the pagetables have already been
> > modified. If get_user_pages runs then the fault handling will occur
> > which will block the thread until migration is complete.
>
> migrate.c does nothing for ptes pointing to swap entries and
> do_swap_page won't wait for them either. Assume follow_page in

If a anonymous page is a swap page then it has a mapping.
migrate_page_move_mapping() will lock the radix tree and ensure that no
additional reference (like done by do_swap_page) is established during
migration.

> However it's not exactly the same bug as the one in fork, I was
> talking about before, it's also not o_direct specific. Still

So far I have seen wild ideas not bugs.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
