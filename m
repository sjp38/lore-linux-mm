From: Kanoj Sarcar <kanoj@google.engr.sgi.com>
Message-Id: <200103020820.AAA35209@google.engr.sgi.com>
Subject: Linux/mips64 on 64 node, 128p, 64G machine
Date: Fri, 2 Mar 2001 00:20:57 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
Cc: torvalds@transmeta.com, Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>

Hi,

Just a quick note to mention that I was successful in booting up a
64 node, 128p, 64G mips64 machine on a 2.4.1 based kernel. To be able
to handle the amount of io devices connected, I had to make some 
fixes in the arch/mips64 code. And a few to handle 128 cpus.

A couple of generic patches needed to be made on top of 2.4.1 
(obviously, the prime one was that NR_CPUS had to be bumped to 128).
I will clean the patches up and send them in to Linus.

For some output, visit

    http://oss.sgi.com/projects/LinuxScalability/download/mips128.out

I ommitted the bootup messages, since they are similar (just a lot
longer!) to the 32p bootup messages at

    http://oss.sgi.com/projects/LinuxScalability/download/mips64.out

Kanoj

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
