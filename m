Date: Fri, 15 Jun 2007 01:15:36 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] memory unplug v5 [1/6] migration by kernel
Message-Id: <20070615011536.beaa79c1.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0706140909030.29612@schroedinger.engr.sgi.com>
References: <20070614155630.04f8170c.kamezawa.hiroyu@jp.fujitsu.com>
	<20070614155929.2be37edb.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706140000400.11433@schroedinger.engr.sgi.com>
	<20070614161146.5415f493.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706140019490.11852@schroedinger.engr.sgi.com>
	<20070614164128.42882f74.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706140044400.22032@schroedinger.engr.sgi.com>
	<20070614172936.12b94ad7.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706140706370.28544@schroedinger.engr.sgi.com>
	<20070615010217.62908da3.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0706140909030.29612@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: linux-mm@kvack.org, mel@csn.ul.ie, y-goto@jp.fujitsu.com, hugh@veritas.com
List-ID: <linux-mm.kvack.org>

On Thu, 14 Jun 2007 09:12:37 -0700 (PDT)
Christoph Lameter <clameter@sgi.com> wrote:

> > An unmapped swapcache page, which is just added to LRU, may be accessed via migrate_page().
> > But page->mapping is NULL yet. 
> 
> Yes then lets add a check for page->mapping == NULL there.
> 
> if (!page->mapping)
> 	goto unlock;
> 
> That will retry the migration on the next pass. Add some concise comment 
> explaining the situation. This is general bug in page migration.
> 
Ok, will do. thank you for your advice.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
