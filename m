Message-ID: <3E1C9257.2040907@us.ibm.com>
Date: Wed, 08 Jan 2003 13:04:23 -0800
From: Dave Hansen <haveblue@us.ibm.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] allow bigger PAGE_OFFSET with PAE
References: <3E1B334E.8030807@us.ibm.com> <20030107233713.GB23814@holomorphy.com>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III wrote:
> On Tue, Jan 07, 2003 at 12:06:38PM -0800, Dave Hansen wrote:
> 
>>Also, this gets the kernel's pagetables right, but neglects 
>>userspace's for now.  pgd_alloc() needs to be fixed to allocate 
>>another PMD, if the split isn't PMD-alighed.
> 
> Um, that should be automatic when USER_PTRS_PER_PGD is increased.

Nope, you need a little bit more.  pgd_alloc() relies on its memcpy() 
to provide the kernel mappings.  After the last user PMD is allocated, 
you still need to copy the kernel-shared part of it in.

-- 
Dave Hansen
haveblue@us.ibm.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
