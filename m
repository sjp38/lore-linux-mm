Date: Mon, 27 Mar 2000 11:46:11 +0100
From: "Stephen C. Tweedie" <sct@redhat.com>
Subject: Re: Why ?
Message-ID: <20000327114611.H1160@redhat.com>
References: <CA2568AF.002D39AF.00@d73mta05.au.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA2568AF.002D39AF.00@d73mta05.au.ibm.com>; from pnilesh@in.ibm.com on Mon, Mar 27, 2000 at 01:36:19PM +0530
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: pnilesh@in.ibm.com
Cc: linux-mm@kvack.org, Stephen Tweedie <sct@redhat.com>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, Mar 27, 2000 at 01:36:19PM +0530, pnilesh@in.ibm.com wrote:
> Why the first 0x0 - 0x07ffffff   virtual addresses are not used by any
> process ?
> Is that used by the kernel and if yes for what ?

No, the entire 3GB user virtual address space is usable by user space.
It's the compiler/linker toolset which requests that ELF binaries be
loaded at 0x08000000.  As for a reason, the only one I'm aware of is
that that's what the ELF standard says. :-)  It does offer a solid
protection against dereferencing uninitialised pointers, though.

--Stephen
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
