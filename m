Received: by ug-out-1314.google.com with SMTP id m2so226711uge
        for <linux-mm@kvack.org>; Wed, 23 May 2007 11:00:50 -0700 (PDT)
Message-ID: <a781481a0705231100q333a589at6c025eb1292019cd@mail.gmail.com>
Date: Wed, 23 May 2007 23:30:50 +0530
From: "Satyam Sharma" <satyam.sharma@gmail.com>
Subject: Re: signals logged / [RFC] log out-of-virtual-memory events
In-Reply-To: <20070521124734.GB14802@vanheusden.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <464C9D82.60105@redhat.com>
	 <Pine.LNX.4.61.0705202235430.13923@yvahk01.tjqt.qr>
	 <20070520205500.GJ22452@vanheusden.com>
	 <200705202314.57758.ak@suse.de>
	 <46517817.1080208@users.sourceforge.net>
	 <20070521110406.GA14802@vanheusden.com>
	 <Pine.LNX.4.61.0705211420100.4452@yvahk01.tjqt.qr>
	 <20070521124734.GB14802@vanheusden.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Folkert van Heusden <folkert@vanheusden.com>
Cc: Jan Engelhardt <jengelh@linux01.gwdg.de>, Andrea Righi <righiandr@users.sourceforge.net>, Andi Kleen <ak@suse.de>, Stephen Hemminger <shemminger@linux-foundation.org>, Eric Dumazet <dada1@cosmosbay.com>, Rik van Riel <riel@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 5/21/07, Folkert van Heusden <folkert@vanheusden.com> wrote:
> > >What about the following enhancement: I check with sig_fatal if it would
> > >kill the process and only then emit a message. So when an application
> > >takes care itself of handling it nothing is printed.
> > >+    /* emit some logging for unhandled signals
> > >+     */
> > >+    if (sig_fatal(t, sig))
> > Not unhandled_signal()?
>
> Can we already use that one in send_signal? As the signal needs to be
> send first I think before we know if it was handled or not? sig_fatal
> checks if the handler is set to default - which is it is not taken care
> of.
>
> > >+    {
> > if (sig_fatal(t, sig)) {
> > >+            printk(KERN_WARNING "Sig %d send to %d owned by %d.%d (%s)\n",
> > s/send/sent/;
> > >+            sig, t -> pid, t -> uid, t -> gid, t -> comm);
> > t->pid, t->uid, t->gid, t->comm);
>
>
> Description:
> This patch adds code to the signal-sender making it log a message when
> an unhandled fatal signal will be delivered.

Gargh ... why does this want to be in the *kernel*'s logs? In any case, can
you please make this KERN_INFO (or lower) instead of KERN_WARNING.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
