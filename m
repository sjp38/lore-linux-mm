Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 0B0606005A4
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 22:27:11 -0500 (EST)
Date: Tue, 5 Jan 2010 12:26:33 +0900
From: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>
Subject: [stable][BUGFIX][PATCH v3] memcg: avoid oom-killing innocent task
 in case of use_hierarchy
Message-Id: <20100105122633.28738255.d-nishimura@mtf.biglobe.ne.jp>
In-Reply-To: <20100104222818.GA20708@kroah.com>
References: <20091124145759.194cfc9f.nishimura@mxp.nes.nec.co.jp>
	<20091124162854.fb31e81e.nishimura@mxp.nes.nec.co.jp>
	<20091125090050.e366dca5.kamezawa.hiroyu@jp.fujitsu.com>
	<20091125143218.96156a5f.nishimura@mxp.nes.nec.co.jp>
	<20091217094724.15ec3b27.nishimura@mxp.nes.nec.co.jp>
	<20100104222818.GA20708@kroah.com>
Reply-To: nishimura@mxp.nes.nec.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Greg KH <greg@kroah.com>
Cc: stable <stable@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 4 Jan 2010 14:28:19 -0800
Greg KH <greg@kroah.com> wrote:

> On Thu, Dec 17, 2009 at 09:47:24AM +0900, Daisuke Nishimura wrote:
> > Stable team.
> > 
> > Cay you pick this up for 2.6.32.y(and 2.6.31.y if it will be released) ?
> > 
> > This is a for-stable version of a bugfix patch that corresponds to the
> > upstream commmit d31f56dbf8bafaacb0c617f9a6f137498d5c7aed.
> 
> I've applied it to the .32-stable tree, but it does not apply to .31.
> Care to provide a version of the patch for that kernel if you want it
> applied there?
> 
hmm, strange. I can apply it onto 2.6.31.9. It might conflict with other patches
in 2.6.31.y queue ?
Anyway, I've attached the patch that is rebased on 2.6.31.9. Please tell me if you
have any problem with it.

v3: rebased on 2.6.31.9
===
