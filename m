Received: from pneumatic-tube.sgi.com (pneumatic-tube.sgi.com [204.94.214.22])
	by kvack.org (8.8.7/8.8.7) with ESMTP id NAA08535
	for <linux-mm@kvack.org>; Fri, 16 Apr 1999 13:37:52 -0400
From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199904161735.KAA37069@google.engr.sgi.com>
Subject: questions on ia32 smp_flush_tlb
Date: Fri, 16 Apr 1999 10:35:37 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,

I am curious about the smp_flush_tlb() ia32 code in arch/i386/kernel/smp.c.

Firstly, is it guaranteed that all callers of this routine hold the giant
kernel lock? Or could it be called without the lock?

Secondly, what is the reason of the __save_flags/__cli/__restore_flags in
the body of smp_flush_tlb? I noted there are some FORCE_APIC_SERIALIZATION/
CONFIG_X86_GOOD_APIC issues, but those are well contained in 
send_IPI_allbutself, so smp_flush_tlb should not need to redo it, according
to my simple thinking. 

Thirdly, depending on whether smp_flush_tlb is always called with the
kernel_lock (see first question), how is it possible to get "crossing"
invalidates?

Fourthly, wouldn't it be better if the caller were to do its local_flush_tlb
and then go into the while loop, waiting for other cpus to finish their
flushes? This way, it would probably spend lesser time spinning ... yes,
this is just microoptimization.

Please CC me (kanoj@engr.sgi.com) on your replies.

Thanks much.

Kanoj
(kanoj@engr.sgi.com)

--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
