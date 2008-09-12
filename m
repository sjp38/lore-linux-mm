Date: Fri, 12 Sep 2008 19:18:28 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] [PATCH 0/9]  remove page_cgroup pointer (with some
 enhancements)
Message-Id: <20080912191828.58657b03.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080912183540.6e7d2468.kamezawa.hiroyu@jp.fujitsu.com>
References: <20080911200855.94d33d3b.kamezawa.hiroyu@jp.fujitsu.com>
	<20080912183540.6e7d2468.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: balbir@linux.vnet.ibm.com, "xemul@openvz.org" <xemul@openvz.org>, "hugh@veritas.com" <hugh@veritas.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, menage@google.com
List-ID: <linux-mm.kvack.org>

On Fri, 12 Sep 2008 18:35:40 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Execl Throughput                           3064.9 lps   (29.8 secs, 3 samples)
> C Compiler Throughput                       998.0 lpm   (60.0 secs, 3 samples)
> Shell Scripts (1 concurrent)               4717.0 lpm   (60.0 secs, 3 samples)
> Shell Scripts (8 concurrent)                928.3 lpm   (60.0 secs, 3 samples)
> Shell Scripts (16 concurrent)               474.3 lpm   (60.0 secs, 3 samples)
> Dc: sqrt(2) to 99 decimal places         127184.0 lpm   (30.0 secs, 3 samples)
> 
This number is because of BUG. follwoing is fixed one.

Execl Throughput                           3026.0 lps   (29.8 secs, 3 samples)
C Compiler Throughput                       971.0 lpm   (60.0 secs, 3 samples)
Shell Scripts (1 concurrent)               4573.7 lpm   (60.0 secs, 3 samples)
Shell Scripts (8 concurrent)                913.0 lpm   (60.0 secs, 3 samples)
Shell Scripts (16 concurrent)               465.7 lpm   (60.0 secs, 3 samples)
Dc: sqrt(2) to 99 decimal places         125412.1 lpm   (30.0 secs, 3 samples)

not good yet ;(  Very sorry for noise.
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
