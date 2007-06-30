Message-ID: <46868532.7030208@xensource.com>
Date: Sat, 30 Jun 2007 09:30:42 -0700
From: Jeremy Fitzhardinge <jeremy@xensource.com>
MIME-Version: 1.0
Subject: Re: RFC: multiple address spaces for one process
References: <87myynt1m6.wl%peter@chubb.wattle.id.au>	<468517E1.4050803@goop.org> <4685D9C9.20504@de.ibm.com>
In-Reply-To: <4685D9C9.20504@de.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: carsteno@de.ibm.com
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, linux-mm@kvack.org, Peter Chubb <peterc@gelato.unsw.edu.au>, virtualization@lists.linux-foundation.org, Avi Kivity <avi@qumranet.com>
List-ID: <linux-mm.kvack.org>

Carsten Otte wrote:
> The big difference here is that LinuxOnLinux does represent guest 
> virtual addressing in these mm structs where all other kernel based 
> VMMs do represent guest physical in the user address space. That 
> somewhat disqualifies LinuxOnLinux to share the commonality.
> Whether or not proposed patch makes sense for shaddow page tables is 
> unknown to me, since we have nested paging on s390. 

 From an interface perspective, I think nested paging and shadow 
pagetables should be identical; after all, shadow pagetables are just a 
software implementation of nested pagetables.  There seem to be 3 
distinct types of VMM pagetable:

   1. UML/LoL vmas-as-pagetable/tlb
   2. shadow/nested paging
   3. direct paging

The multiple address space patch definitely makes sense for 1, but 2&3 
both implement the alternate address space by directly pointing the 
CPU's paging hardware at a new pagetable, rather than going via the 
Linux VM.

    J

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
