Date: Wed, 5 Sep 2007 15:40:13 -0500
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH][RFC]: pte notifiers -- support for external page tables
Message-ID: <20070905204012.GA29272@sgi.com>
References: <11890103283456-git-send-email-avi@qumranet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <11890103283456-git-send-email-avi@qumranet.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Avi Kivity <avi@qumranet.com>
Cc: lkml@qumranet.com, linux-mm@kvack.org, shaohua.li@intel.com, kvm@qumranet.com, general@lists.openfabrics.org
List-ID: <linux-mm.kvack.org>

On Wed, Sep 05, 2007 at 07:38:48PM +0300, Avi Kivity wrote:
> Some hardware and software systems maintain page tables outside the normal
> Linux page tables, which reference userspace memory.  This includes
> Infiniband, other RDMA-capable devices, and kvm (with a pending patch).
> 

I like it. 

We have 2 special devices with external TLBs that can
take advantage of this.

One suggestion - at least for what we need. Can the notifier be
registered against the mm_struct instead of (or in addition to) the
vma?


---jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
