Message-ID: <3DA41346.186CE3A6@scs.ch>
Date: Wed, 09 Oct 2002 13:30:14 +0200
From: Martin Maletinsky <maletinsky@scs.ch>
MIME-Version: 1.0
Subject: VM_MAY... flags
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kernelnewbies@nl.linux.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

What is the meaning of the VM_MAY.. flags? I.e. what does it mean for example, if the VM_MAYWRITE flag for a vmarea is set, while the VM_WRITE flag is clear (based on the
naming I assume the opposite is not possible)? Where are the VM_MAYWRITE flags set/checked?

The reason for my question is, that I use the get_user_pages() function (exists from kernel 2.4.17), which has a 'force flag' as an argument. In the 2.4.18 version, if the
force flag is set, the function will consider the VM_MAY(READ/WRITE) rather than the VM_(READ/WRITE) flags, to validate the vmarea. Thus I should know the syntax of the
VM_MAY... flags, to decide wether or not to set the force flag.

Thanks in advance for any help
with best regards
Martin Maletinsky


P.S. Please put me on cc: in the reply, since I am not on the mailing list.

--
Supercomputing System AG          email: maletinsky@scs.ch
Martin Maletinsky                 phone: +41 (0)1 445 16 05
Technoparkstrasse 1               fax:   +41 (0)1 445 16 10
CH-8005 Zurich


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
