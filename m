Received: by wa-out-1112.google.com with SMTP id m33so805247wag
        for <linux-mm@kvack.org>; Fri, 09 Nov 2007 11:31:05 -0800 (PST)
Message-ID: <6934efce0711091131n1acd2ce1h7bb17f9f3cb0f235@mail.gmail.com>
Date: Fri, 9 Nov 2007 11:31:05 -0800
From: "Jared Hulbert" <jaredeh@gmail.com>
Subject: Re: about page migration on UMA
In-Reply-To: <Pine.LNX.4.64.0710181825520.4272@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20071016191949.cd50f12f.kamezawa.hiroyu@jp.fujitsu.com>
	 <20071016192341.1c3746df.kamezawa.hiroyu@jp.fujitsu.com>
	 <alpine.DEB.0.9999.0710162113300.13648@chino.kir.corp.google.com>
	 <20071017141609.0eb60539.kamezawa.hiroyu@jp.fujitsu.com>
	 <alpine.DEB.0.9999.0710162232540.27242@chino.kir.corp.google.com>
	 <20071017145009.e4a56c0d.kamezawa.hiroyu@jp.fujitsu.com>
	 <02f001c8108c$a3818760$3708a8c0@arcapub.arca.com>
	 <Pine.LNX.4.64.0710181825520.4272@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: "Jacky(GuangXiang Lee)" <gxli@arca.com.cn>, climeter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 10/18/07, Christoph Lameter <clameter@sgi.com> wrote:
> On Wed, 17 Oct 2007, Jacky(GuangXiang  Lee) wrote:
>
> > seems page migration is used mostly for NUMA platform to improve
> > performance.
> > But in a UMA architecture, Is it possible to use page migration to move
> > pages ?
>
> Yes. Just one up with a usage for it. The page migration mechanism itself
> is not NUMA dependent.

For extreme low power systems it would be possible to shut down banks
in SDRAM chips that were not full thereby saving power.  That would
require some defraging and migration to empty them prior to powering
down those banks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
