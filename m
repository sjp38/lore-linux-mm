Date: Wed, 17 Oct 2007 15:44:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: about page migration on UMA
Message-Id: <20071017154403.7712262c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <02f001c8108c$a3818760$3708a8c0@arcapub.arca.com>
References: <20071016191949.cd50f12f.kamezawa.hiroyu@jp.fujitsu.com>
	<20071016192341.1c3746df.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.0.9999.0710162113300.13648@chino.kir.corp.google.com>
	<20071017141609.0eb60539.kamezawa.hiroyu@jp.fujitsu.com>
	<alpine.DEB.0.9999.0710162232540.27242@chino.kir.corp.google.com>
	<20071017145009.e4a56c0d.kamezawa.hiroyu@jp.fujitsu.com>
	<02f001c8108c$a3818760$3708a8c0@arcapub.arca.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Jacky(GuangXiang  Lee)" <gxli@arca.com.cn>
Cc: climeter@sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 17 Oct 2007 15:09:19 +0800
"Jacky(GuangXiang  Lee)" <gxli@arca.com.cn> wrote:

> seems page migration is used mostly for NUMA platform to improve
> performance.
> But in a UMA architecture, Is it possible to use page migration to move
> pages ?
> 

Currently no usage. but someone  (Mel ?) will use migration code to do 
page defragmentation. In that case, migration will be used.
For memory hot remove, we will need to enable migration on UMA.
(but I don't hear requests to do that...)

But, sys_move_pages() will not work on UMA.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
