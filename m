Date: Fri, 9 Nov 2007 11:36:59 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: about page migration on UMA
In-Reply-To: <6934efce0711091131n1acd2ce1h7bb17f9f3cb0f235@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0711091136270.15605@schroedinger.engr.sgi.com>
References: <20071016191949.cd50f12f.kamezawa.hiroyu@jp.fujitsu.com>
 <20071016192341.1c3746df.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.0.9999.0710162113300.13648@chino.kir.corp.google.com>
 <20071017141609.0eb60539.kamezawa.hiroyu@jp.fujitsu.com>
 <alpine.DEB.0.9999.0710162232540.27242@chino.kir.corp.google.com>
 <20071017145009.e4a56c0d.kamezawa.hiroyu@jp.fujitsu.com>
 <02f001c8108c$a3818760$3708a8c0@arcapub.arca.com>
 <Pine.LNX.4.64.0710181825520.4272@schroedinger.engr.sgi.com>
 <6934efce0711091131n1acd2ce1h7bb17f9f3cb0f235@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>
Cc: "Jacky(GuangXiang Lee)" <gxli@arca.com.cn>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 9 Nov 2007, Jared Hulbert wrote:

> For extreme low power systems it would be possible to shut down banks
> in SDRAM chips that were not full thereby saving power.  That would
> require some defraging and migration to empty them prior to powering
> down those banks.

Yes we have discussed ideas like that a couple of time. If you do have the 
time then please make this work. You have my full support.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
