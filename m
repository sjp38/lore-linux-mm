Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 7282A6B004F
	for <linux-mm@kvack.org>; Tue, 11 Aug 2009 10:57:17 -0400 (EDT)
Message-ID: <4A81863A.2050504@redhat.com>
Date: Tue, 11 Aug 2009 10:54:50 -0400
From: Prarit Bhargava <prarit@redhat.com>
MIME-Version: 1.0
Subject: Re: Help Resource Counters Scale better (v4)
References: <20090811144405.GW7176@balbir.in.ibm.com>
In-Reply-To: <20090811144405.GW7176@balbir.in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "menage@google.com" <menage@google.com>, andi.kleen@intel.com, Pavel Emelianov <xemul@openvz.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



Balbir Singh wrote:
> Enhancement: Remove the overhead of root based resource counter accounting
>
>
>   

<snip>
> Please test/review.
>
>   
FWIW ...

On a 64p/32G system running 2.6.31-git2-rc5, with RESOURCE_COUNTERS off, 
"time make -j64" results in

real    4m54.972s
user    90m13.456s
sys     50m19.711s

On the same system, running 2.6.31-git2-rc5, with RESOURCE_COUNTERS on,
plus Balbir's "Help Resource Counters Scale Better (v3)" patch, and this 
patch, results in

 real    4m18.607s
user    84m58.943s
sys     50m52.682s

P.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
