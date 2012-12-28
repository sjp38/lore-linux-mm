Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 69C268D0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 19:42:15 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 18B893EE0C5
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 09:42:14 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E3C5645DEC4
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 09:42:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C5DE745DEB7
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 09:42:13 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id B371C1DB8042
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 09:42:13 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 66E1E1DB803C
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 09:42:13 +0900 (JST)
Message-ID: <50DCEAC8.7000600@jp.fujitsu.com>
Date: Fri, 28 Dec 2012 09:41:44 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH V3 3/8] use vfs __set_page_dirty interface instead of
 doing it inside filesystem
References: <1356455919-14445-1-git-send-email-handai.szj@taobao.com> <1356456261-14579-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1356456261-14579-1-git-send-email-handai.szj@taobao.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, ceph-devel@vger.kernel.org, sage@newdream.net, dchinner@redhat.com, mhocko@suse.cz, akpm@linux-foundation.org, gthelen@google.com, fengguang.wu@intel.com, glommer@parallels.com, Sha Zhengju <handai.szj@taobao.com>

(2012/12/26 2:24), Sha Zhengju wrote:
> From: Sha Zhengju <handai.szj@taobao.com>
> 
> Following we will treat SetPageDirty and dirty page accounting as an integrated
> operation. Filesystems had better use vfs interface directly to avoid those details.
> 
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>
> Acked-by: Sage Weil <sage@inktank.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
