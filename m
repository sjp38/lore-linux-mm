Date: Thu, 18 Oct 2007 18:26:20 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: about page migration on UMA
In-Reply-To: <02f001c8108c$a3818760$3708a8c0@arcapub.arca.com>
Message-ID: <Pine.LNX.4.64.0710181825520.4272@schroedinger.engr.sgi.com>
References: <20071016191949.cd50f12f.kamezawa.hiroyu@jp.fujitsu.com><20071016192341.1c3746df.kamezawa.hiroyu@jp.fujitsu.com><alpine.DEB.0.9999.0710162113300.13648@chino.kir.corp.google.com><20071017141609.0eb60539.kamezawa.hiroyu@jp.fujitsu.com><alpine.DEB.0.9999.0710162232540.27242@chino.kir.corp.google.com>
 <20071017145009.e4a56c0d.kamezawa.hiroyu@jp.fujitsu.com>
 <02f001c8108c$a3818760$3708a8c0@arcapub.arca.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Jacky(GuangXiang  Lee)" <gxli@arca.com.cn>
Cc: climeter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Oct 2007, Jacky(GuangXiang  Lee) wrote:

> seems page migration is used mostly for NUMA platform to improve
> performance.
> But in a UMA architecture, Is it possible to use page migration to move
> pages ?

Yes. Just one up with a usage for it. The page migration mechanism itself 
is not NUMA dependent.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
