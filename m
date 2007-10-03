Date: Wed, 3 Oct 2007 09:29:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [BUGFIX][RFC][PATCH][only -mm] FIX memory leak in memory cgroup
 vs. page migration [2/1] additional patch for migrate page/memory cgroup
Message-Id: <20071003092909.4ec588fe.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4702657B.9060501@linux.vnet.ibm.com>
References: <20071002183031.3352be6a.kamezawa.hiroyu@jp.fujitsu.com>
	<20071002183306.0c132ff4.kamezawa.hiroyu@jp.fujitsu.com>
	<20071002191217.61b4cf77.kamezawa.hiroyu@jp.fujitsu.com>
	<4702657B.9060501@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Tue, 02 Oct 2007 21:06:27 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> > The patch I sent needs following fix, sorry.
> > Anyway, I'll repost good-version with reflected comments again.
> > 
> > Thanks,
> >  -Kame
> 
> Just saw this now, I'll apply both the fixes, but it would be helpful
> if you could post, one combined patch.
> 
Yes, I'll post refleshed easy-to-review version again. 
I'm now planing to post a patch against next -mm.

Thanks,
-Kame 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
