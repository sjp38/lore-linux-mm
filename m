Date: Thu, 23 May 2002 15:33:21 -0700
From: William Lee Irwin III <wli@holomorphy.com>
Subject: Re: [bcrl@redhat.com: [PATCH] 2.4.19-pre8 vm86 smp locking fix]
Message-ID: <20020523223321.GB2035@holomorphy.com>
References: <20020523165736.B27881@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Description: brief message
Content-Disposition: inline
In-Reply-To: <20020523165736.B27881@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, May 23, 2002 at 04:57:36PM -0400, Benjamin LaHaise wrote:
> arch/i386/kernel/vm86.c performs page table operations without obtaining 
> any locks.  This patch obtains page_table_lock around the the table walk 
> and modification.

Looks correct to me; IMHO it should be applied.


Cheers,
Bill
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
