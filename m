Date: Mon, 15 Jul 2002 09:02:40 -0500
From: Dave McCracken <dmccr@us.ibm.com>
Subject: Re: [PATCH] Optimize away pte_chains for single mappings
Message-ID: <10930000.1026741760@baldur.austin.ibm.com>
In-Reply-To: <E17TMiO-0003IR-00@starship>
References: <55160000.1026239746@baldur.austin.ibm.com>
 <E17TMiO-0003IR-00@starship>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel Phillips <phillips@arcor.de>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--On Saturday, July 13, 2002 03:13:35 PM +0200 Daniel Phillips
<phillips@arcor.de> wrote:

> Why are we using up valuable real estate in page->flags when the low bit
> of page->pte_chain is available?

Right now my flag is bit number 18 in page->flags out of 32.  Mechanisms
already exist to manipulate this bit in a reasonable fashion.  I don't see
any good reason for complicating things by putting a flag bit into a
pointer, where we'd have to repeatedly check and clear it before we
dereference the pointer.  When I discussed this with Rik he said putting it
in flags was reasonable.  We can always revisit it in the future if we run
out of bits.

Dave

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmccr@us.ibm.com                                        T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
