Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id 77AB86B004D
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 03:22:26 -0500 (EST)
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 25 Jan 2012 01:22:25 -0700
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id BFA101FF004C
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 01:22:22 -0700 (MST)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0P8MMYT290870
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 03:22:22 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0P8MKhd020209
	for <linux-mm@kvack.org>; Wed, 25 Jan 2012 06:22:22 -0200
Date: Wed, 25 Jan 2012 13:42:23 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v9 3.2 2/9] uprobes: handle breakpoint and signal step
 exception.
Message-ID: <20120125081223.GC24766@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20120110114821.17610.9188.sendpatchset@srdronam.in.ibm.com>
 <201201180518.31407.vapier@gentoo.org>
 <20120118104749.GG15447@linux.vnet.ibm.com>
 <201201180602.04269.vapier@gentoo.org>
 <CAMjpGUc+V-mrQcBcpyTvhCihYUtd=4Q4Wr6DTsaUwC0JJpBROA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAMjpGUc+V-mrQcBcpyTvhCihYUtd=4Q4Wr6DTsaUwC0JJpBROA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Frysinger <vapier@gentoo.org>
Cc: Anton Arapov <anton@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>

> >>
> >> One question that could be asked is why arent we using instruction_pointer
> >> instead of GET_IP since instruction_pointer is being defined in 25
> >> places and with references in 120 places.
> >
> > i think you misunderstand the point.  {G,S}ET_IP() is the glue between the
> > arch's pt_regs struct and the public facing API.  the only people who should
> > be touching those macros are the ptrace core.  instruction_pointer() and
> > instruction_pointer_set() are the API that asm/ptrace.h exports to the rest of
> > the tree.
> 
> Srikar: does that make sense ?  i'm happy to help with improving
> asm-generic/ptrace.h.
> -mike
> 

Yes, I think it makes sense. I have modified the code to use
instruction_pointer_set instead of set_instruction_pointer.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
