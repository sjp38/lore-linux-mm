Date: Wed, 8 Jan 2003 14:05:33 -0800
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [RFC][PATCH] allow bigger PAGE_OFFSET with PAE
Message-ID: <20030108220533.GD23814@holomorphy.com>
References: <3E1B334E.8030807@us.ibm.com> <20030107233713.GB23814@holomorphy.com> <3E1C9257.2040907@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <3E1C9257.2040907@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jan 07, 2003 at 12:06:38PM -0800, Dave Hansen wrote:
>>> Also, this gets the kernel's pagetables right, but neglects 
>>> userspace's for now.  pgd_alloc() needs to be fixed to allocate 
>>> another PMD, if the split isn't PMD-alighed.

William Lee Irwin III wrote:
>> Um, that should be automatic when USER_PTRS_PER_PGD is increased.

On Wed, Jan 08, 2003 at 01:04:23PM -0800, Dave Hansen wrote:
> Nope, you need a little bit more.  pgd_alloc() relies on its memcpy() 
> to provide the kernel mappings.  After the last user PMD is allocated, 
> you still need to copy the kernel-shared part of it in.

See the bit about rounding up. Then again, the pmd entries don't get
filled in by any of that...


Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
