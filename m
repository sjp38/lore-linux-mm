Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CA2606B003D
	for <linux-mm@kvack.org>; Sun, 29 Mar 2009 10:38:25 -0400 (EDT)
Message-ID: <49CF87FB.4030608@redhat.com>
Date: Sun, 29 Mar 2009 10:38:51 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 0/6] Guest page hinting version 7.
References: <20090327150905.819861420@de.ibm.com>	<1238195024.8286.562.camel@nimitz>	<49CD69EB.6000000@redhat.com> <20090329162024.687196ab@skybase>
In-Reply-To: <20090329162024.687196ab@skybase>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Dave Hansen <dave@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.osdl.org, frankeh@watson.ibm.com, akpm@osdl.org, nickpiggin@yahoo.com.au, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

Martin Schwidefsky wrote:
> On Fri, 27 Mar 2009 20:06:03 -0400
> Rik van Riel <riel@redhat.com> wrote:
> 
>> Dave Hansen wrote:
>>> On Fri, 2009-03-27 at 16:09 +0100, Martin Schwidefsky wrote:
>>>> If the host picks one of the
>>>> pages the guest can recreate, the host can throw it away instead of writing
>>>> it to the paging device. Simple and elegant.
>>> Heh, simple and elegant for the hypervisor.  But I'm not sure I'm going
>>> to call *anything* that requires a new CPU instruction elegant. ;)
>> I am convinced that it could be done with a guest-writable
>> "bitmap", with 2 bits per page.  That would make this scheme
>> useful for KVM, too.
> 
> This was our initial approach before we came up with the milli-code
> instruction. The reason we did not use a bitmap was to prevent the
> guest to change the host state (4 guest states U/S/V/P and 3 host
> states r/p/z). With the full set of states you'd need 4 bits. And the
> hosts need to have a "master" copy of the host bits, one the guest
> cannot change, otherwise you get into trouble.

KVM already has the info from the host bits somewhere else,
which is needed to be able to actually find the physical
pages used by a guest.

That leaves just the guest states, so a compare-and-swap may
work for non-s390.

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
