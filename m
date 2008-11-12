Date: Wed, 12 Nov 2008 14:31:18 -0600 (CST)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 2/4] Add replace_page(), change the mapping of pte from
 one page into another
In-Reply-To: <1226520487.7560.65.camel@lts-notebook>
Message-ID: <Pine.LNX.4.64.0811121428120.31606@quilx.com>
References: <1226409701-14831-3-git-send-email-ieidus@redhat.com>
 <20081111114555.eb808843.akpm@linux-foundation.org>  <20081111210655.GG10818@random.random>
  <Pine.LNX.4.64.0811111522150.27767@quilx.com>  <20081111221753.GK10818@random.random>
  <Pine.LNX.4.64.0811111626520.29222@quilx.com>  <20081111231722.GR10818@random.random>
  <Pine.LNX.4.64.0811111823030.31625@quilx.com>  <20081112022701.GT10818@random.random>
  <Pine.LNX.4.64.0811112109390.10501@quilx.com>  <20081112173258.GX10818@random.random>
 <1226520487.7560.65.camel@lts-notebook>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Izik Eidus <ieidus@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, chrisw@redhat.com, avi@redhat.com, izike@qumranet.com
List-ID: <linux-mm.kvack.org>

On Wed, 12 Nov 2008, Lee Schermerhorn wrote:

> Might want/need to check for migration entry in do_swap_page() and loop
> back to migration_entry_wait() call when the changed pte is detected
> rather than returning an error to the caller.
>
> Does that sound reasonable?

The reference count freezing and the rechecking of the pte in
do_swap_page() does not work? Nick broke it during lock removal for the
lockless page cache?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
