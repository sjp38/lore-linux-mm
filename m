Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 287628D0039
	for <linux-mm@kvack.org>; Tue,  8 Mar 2011 02:28:07 -0500 (EST)
Date: Mon, 7 Mar 2011 23:27:53 -0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH V2] page-types.c: auto debugfs mount for hwpoison
 operation
Message-ID: <20110308072753.GA26747@localhost>
References: <1299487900-7792-1-git-send-email-gong.chen@linux.intel.com>
 <20110307184133.8A19.A69D9226@jp.fujitsu.com>
 <20110307113937.GB5080@localhost>
 <4D75B815.2080603@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4D75B815.2080603@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Gong <gong.chen@linux.intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Ingo Molnar <mingo@elte.hu>, Clark Williams <williams@redhat.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>

On Tue, Mar 08, 2011 at 01:01:09PM +0800, Chen Gong wrote:
> page-types.c doesn't supply a way to specify the debugfs path and
> the original debugfs path is not usual on most machines. This patch
> supplies a way to auto mount debugfs if needed.
> 
> This patch is heavily inspired by tools/perf/utils/debugfs.c
> 
> Signed-off-by: Chen Gong <gong.chen@linux.intel.com>
> ---
>   Documentation/vm/page-types.c |  105 
> +++++++++++++++++++++++++++++++++++++++--
>   1 files changed, 101 insertions(+), 4 deletions(-)

Thanks!

Reviewed-by: Wu Fengguang <fengguang.wu@intel.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
