Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id B85AC6B005D
	for <linux-mm@kvack.org>; Tue, 24 Mar 2009 19:36:18 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2ONuW0L005420
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 25 Mar 2009 08:56:32 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 381BD45DE57
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 08:56:32 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 063E145DE53
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 08:56:32 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id AAD04E08006
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 08:56:31 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 54C661DB805B
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 08:56:31 +0900 (JST)
Date: Wed, 25 Mar 2009 08:55:05 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 0/5] Memory controller soft limit patches (v7)
Message-Id: <20090325085505.35d14b38.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090324173414.GB24227@balbir.in.ibm.com>
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
	<20090324173414.GB24227@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 24 Mar 2009 23:04:14 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> I've run lmbench with the soft limit patches and the results show no
> major overhead, there are some outliers and unexpected results.
> 
> The outliers are at context-switch 16p/64K, in communicating
> latencies and some unexpected results where the softlimit changes help improve
> performance (I consider these to be in the range of noise).
> 

ok, seems no regressions. but what is the softlimit value ?
I think there result is of course souftlimit=0 case value...right ?

-Kame

>                  L M B E N C H  2 . 0   S U M M A R Y
>                  ------------------------------------
> 
> 
> Basic system parameters
> ----------------------------------------------------
> Host                 OS Description              Mhz
>                                                     
> --------- ------------- ----------------------- ----
> nosoftlim Linux 2.6.29-        x86_64-linux-gnu 2131
> softlimit Linux 2.6.29-        x86_64-linux-gnu 2131
> 
> Processor, Processes - times in microseconds - smaller is better
> ----------------------------------------------------------------
> Host                 OS  Mhz null null      open selct sig  sig  fork exec sh  
>                              call  I/O stat clos TCP   inst hndl proc proc proc
> --------- ------------- ---- ---- ---- ---- ---- ----- ---- ---- ----
> ---- ----
> nosoftlim Linux 2.6.29- 2131 0.67 1.33 29.9 36.8 6.484 1.12 12.1 508. 1708 6281
> softlimit Linux 2.6.29- 2131 0.66 1.31 29.8 36.8 6.486 1.11 12.3 483. 1697 6241
> 
> Context switching - times in microseconds - smaller is better
> -------------------------------------------------------------
> Host                 OS 2p/0K 2p/16K 2p/64K 8p/16K 8p/64K 16p/16K 16p/64K
>                         ctxsw  ctxsw  ctxsw ctxsw  ctxsw   ctxsw ctxsw
> --------- ------------- ----- ------ ------ ------ ------ --------------
> nosoftlim Linux 2.6.29- 2.190 9.2300 3.1900 9.7400   10.8 7.93000 4.36000
> softlimit Linux 2.6.29- 0.970 4.8200 3.1300 8.8900   10.3 8.82000 10.7
> 
> *Local* Communication latencies in microseconds - smaller is better
> -------------------------------------------------------------------
> Host                 OS 2p/0K  Pipe AF     UDP  RPC/   TCP  RPC/ TCP
>                         ctxsw       UNIX         UDP         TCP conn
> --------- ------------- ----- ----- ---- ----- ----- ----- ----- ----
> nosoftlim Linux 2.6.29- 2.190  22.0 58.5  53.3  68.7  61.7  64.9 210.
> softlimit Linux 2.6.29- 0.970  20.3 55.3  54.0  53.8  79.7  64.5 211.
> 
> File & VM system latencies in microseconds - smaller is better
> --------------------------------------------------------------
> Host                 OS   0K File      10K File      Mmap    Prot Page    
>                         Create Delete Create Delete  Latency Fault Fault 
> --------- ------------- ------ ------ ------ ------  ------- ----- ----- 
> nosoftlim Linux 2.6.29-   51.6   48.6  153.6   87.4    20.2K 7.00000
> softlimit Linux 2.6.29-   51.6   48.2  137.8   83.9    20.2K 6.00000
> 
> *Local* Communication bandwidths in MB/s - bigger is better
> -----------------------------------------------------------
> Host                OS  Pipe AF    TCP  File   Mmap  Bcopy  Bcopy  Mem
> Mem
>                              UNIX      reread reread (libc) (hand) read write
> --------- ------------- ---- ---- ---- ------ ------ ------ ------ ---- -----
> nosoftlim Linux 2.6.29- 1367 778. 803. 2058.5 4659.4 1303.9 1303.5 4664 1422.
> softlimit Linux 2.6.29- 1314 823. 812. 2061.3 4659.9 1290.2 1280.9 4662 1422.
> 
> Memory latencies in nanoseconds - smaller is better
>     (WARNING - may not be correct, check graphs)
> ---------------------------------------------------
> Host                 OS   Mhz  L1 $   L2 $    Main mem    Guesses
> --------- -------------  ---- ----- ------    --------    -------
> nosoftlim Linux 2.6.29-  2131 1.875 6.5990   76.8
> softlimit Linux 2.6.29-  2131 1.875 6.5980   76.8
> 
> Earlier, I ran reaim and saw no regression there as well.
> 
> -- 
> 	Balbir
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
