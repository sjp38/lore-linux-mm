Message-ID: <39F9BDB2.8C0CFE94@sgi.com>
Date: Fri, 27 Oct 2000 10:38:58 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Re: page fault.
References: <Pine.LNX.4.21.0010261752510.15696-100000@duckman.distro.conectiva> <Pine.GSO.4.05.10010262213310.16485-100000@aa.eps.jhu.edu> <8tboe4$3bfb7$1@fido.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"Stephen C. Tweedie" wrote:
> 
> Hi,
> 
> On Thu, Oct 26, 2000 at 10:14:23PM -0400, afei@jhu.edu wrote:
> > You are right. I misunderstood what he wants. To know when the pagefault
> > occured, one simply can work on the pagefault handler. It is trivial.
> 
> Page faults already produce a SIGSEGV which gets passed a sigcontext
> struct describing where the fault occurred.
> 

Isn't it that only unsatisfied pagefaults generate
SIGSEGV? The original question was whether there
is a way to track all pagefaults in a given program.
Please correct if I'm wrong: the answer to this latter
question is no. Unless one modifies do_pagefault to
generate such a signal on all faults ...


--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
