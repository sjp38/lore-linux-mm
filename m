Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id DEA788D0001
	for <linux-mm@kvack.org>; Thu, 27 Dec 2012 20:10:52 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 8072B3EE0CE
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 10:10:51 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6720445DEB2
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 10:10:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FD6945DEBB
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 10:10:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 40BED1DB803F
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 10:10:51 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E7F811DB8040
	for <linux-mm@kvack.org>; Fri, 28 Dec 2012 10:10:50 +0900 (JST)
Message-ID: <50DCF185.7050408@jp.fujitsu.com>
Date: Fri, 28 Dec 2012 10:10:29 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH V3 8/8] memcg: Document cgroup dirty/writeback memory
 statistics
References: <1356455919-14445-1-git-send-email-handai.szj@taobao.com> <1356456501-14818-1-git-send-email-handai.szj@taobao.com>
In-Reply-To: <1356456501-14818-1-git-send-email-handai.szj@taobao.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sha Zhengju <handai.szj@gmail.com>
Cc: linux-kernel@vger.kernel.org, cgroups@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.cz, akpm@linux-foundation.org, gthelen@google.com, fengguang.wu@intel.com, glommer@parallels.com, Sha Zhengju <handai.szj@taobao.com>

(2012/12/26 2:28), Sha Zhengju wrote:
> From: Sha Zhengju <handai.szj@taobao.com>
> 
> Signed-off-by: Sha Zhengju <handai.szj@taobao.com>

I don't think your words are bad but it may be better to sync with meminfo's text.

> ---
>   Documentation/cgroups/memory.txt |    2 ++
>   1 file changed, 2 insertions(+)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index addb1f1..2828164 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -487,6 +487,8 @@ pgpgin		- # of charging events to the memory cgroup. The charging
>   pgpgout		- # of uncharging events to the memory cgroup. The uncharging
>   		event happens each time a page is unaccounted from the cgroup.
>   swap		- # of bytes of swap usage
> +dirty          - # of bytes of file cache that are not in sync with the disk copy.
> +writeback      - # of bytes of file/anon cache that are queued for syncing to disk.
>   inactive_anon	- # of bytes of anonymous memory and swap cache memory on
>   		LRU list.
>   active_anon	- # of bytes of anonymous and swap cache memory on active
> 

Documentation/filesystems/proc.txt

       Dirty: Memory which is waiting to get written back to the disk
   Writeback: Memory which is actively being written back to the disk

even if others are not ;(

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
