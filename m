Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 659EF6B01E8
	for <linux-mm@kvack.org>; Mon, 21 Jun 2010 10:29:56 -0400 (EDT)
Date: Mon, 21 Jun 2010 16:29:53 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [Lsf10-pc] Current MM topics for LSF10/MM Summit 8-9 August in
 Boston
Message-ID: <20100621142952.GZ5787@random.random>
References: <1276721459.2847.399.camel@mulgrave.site>
 <20100621120526.GA31679@laptop>
 <20100621131608.GW5787@random.random>
 <20100621132238.GK4689@redhat.com>
 <20100621140939.GY5787@random.random>
 <20100621141855.GN4689@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100621141855.GN4689@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Gleb Natapov <gleb@redhat.com>
Cc: Nick Piggin <npiggin@suse.de>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, lsf10-pc@lists.linuxfoundation.org, linux-scsi@vger.kernel.org, avi@redhat.com
List-ID: <linux-mm.kvack.org>

On Mon, Jun 21, 2010 at 05:18:56PM +0300, Gleb Natapov wrote:
> Avi did the fix. We discussed using MADV_DONTFORK for that, but calling
> madvise() from kernel deemed to be messy.

Agree that calling madvise looks messy. It's possible to set
VM_DONTCOPY under mmap_sem write mode and it'll work as well.

But surely we can as well keep this quicker fix until the fork vs gup
race is fixed, and back it out later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
