Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2916A8D0039
	for <linux-mm@kvack.org>; Mon,  7 Mar 2011 06:40:29 -0500 (EST)
Date: Mon, 7 Mar 2011 19:39:37 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] page-types.c: add a new argument of debugfs path
Message-ID: <20110307113937.GB5080@localhost>
References: <1299487900-7792-1-git-send-email-gong.chen@linux.intel.com>
 <20110307184133.8A19.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110307184133.8A19.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Chen Gong <gong.chen@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@elte.hu>, Clark Williams <williams@redhat.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>

On Mon, Mar 07, 2011 at 05:42:39PM +0800, KOSAKI Motohiro wrote:
> > page-types.c doesn't supply a way to specify the debugfs path and
> > the original debugfs path is not usual on most machines. Add a
> > new argument to set the debugfs path easily.
> > 
> > Signed-off-by: Chen Gong <gong.chen@linux.intel.com>
> 
> Hi
> 
> Why do we need to set debugfs path manually? Instead I'd suggested to
> read /proc/mount and detect it automatically.

Good idea! And could reuse tools/perf/util/debugfs.c for finding out
and even audo-mounting debugfs. 

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
