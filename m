Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx119.postini.com [74.125.245.119])
	by kanga.kvack.org (Postfix) with SMTP id 81FF36B13F0
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 04:52:15 -0500 (EST)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 8 Feb 2012 02:52:14 -0700
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id B538D3E4004C
	for <linux-mm@kvack.org>; Wed,  8 Feb 2012 02:52:11 -0700 (MST)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q189qBuw101852
	for <linux-mm@kvack.org>; Wed, 8 Feb 2012 02:52:11 -0700
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q189q9mb008474
	for <linux-mm@kvack.org>; Wed, 8 Feb 2012 02:52:10 -0700
Date: Wed, 8 Feb 2012 15:10:09 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v10 3.3-rc2 1/9] uprobes: Install and remove
 breakpoints.
Message-ID: <20120208094009.GB24443@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20120202141840.5967.39687.sendpatchset@srdronam.in.ibm.com>
 <20120202141851.5967.68000.sendpatchset@srdronam.in.ibm.com>
 <20120207171707.GA24443@linux.vnet.ibm.com>
 <CAK1hOcOd3hd31vZYw1yAVGK=gMV=vQotL1mRZkVgM=7M8mbMyw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAK1hOcOd3hd31vZYw1yAVGK=gMV=vQotL1mRZkVgM=7M8mbMyw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Denys Vlasenko <vda.linux@googlemail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Rothwell <sfr@canb.auug.org.au>

* Denys Vlasenko <vda.linux@googlemail.com> [2012-02-08 10:40:30]:

> On Tue, Feb 7, 2012 at 6:17 PM, Srikar Dronamraju
> <srikar@linux.vnet.ibm.com> wrote:
> > Changelog: (Since v10): Add code to clear REX.B prefix pointed out by Denys Vlasenko
> > and fix suggested by Masami Hiramatsu.
> ...
> > +       /*
> > +        * Point cursor at the modrm byte.  The next 4 bytes are the
> > +        * displacement.  Beyond the displacement, for some instructions,
> > +        * is the immediate operand.
> > +        */
> > +       cursor = uprobe->insn + insn_offset_modrm(insn);
> > +       insn_get_length(insn);
> > +       if (insn->rex_prefix.nbytes)
> > +               *cursor &= 0xfe;        /* Clearing REX.B bit */
> 
> It looks like cursor points to mod/reg/rm byte, not rex byte.
> Comment above says it too. You seem to be clearing a bit
> in a wrong byte. I think it should be


Oh okay, Will correct this and send out a new patch.


> 
>         /* Clear REX.b bit (extension of MODRM.rm field):
>          * we want to encode rax/rcx, not r8/r9.
>          */
>         if (insn->rex_prefix.nbytes)
>                 insn->rex_prefix.bytes[0] &= 0xfe;

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
