Message-ID: <39F897AC.4A97EAD3@sgi.com>
Date: Thu, 26 Oct 2000 13:44:28 -0700
From: Rajagopal Ananthanarayanan <ananth@sgi.com>
MIME-Version: 1.0
Subject: Re: page fault.
References: <8ta1ir$358it$1@fido.engr.sgi.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "M.Jagadish Kumar" <jagadish@rishi.serc.iisc.ernet.in>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

"M.Jagadish Kumar" wrote:
> 
> hello,
> Is there any way in which i can know when the pagefault occured,
> i mean at what instruction of my program execution.
> Does OS provide any support. This would help me to improve my program.


Unless the test program is the only one on the system,
there are other programs which will affect the pagefault
of the test program,  since the pages of those other programs
affect the resident pages of the test program.

AFAICT, there is no direct means of saying which instructions
caused page faults ... things like /sbin/time can report
total page faults only.

Why are you specifically interested in page faults?

--------------------------------------------------------------------------
Rajagopal Ananthanarayanan ("ananth")
Member Technical Staff, SGI.
--------------------------------------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
