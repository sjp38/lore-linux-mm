Message-ID: <48D58401.4070403@linux-foundation.org>
Date: Sat, 20 Sep 2008 18:15:13 -0500
From: Christoph Lameter <cl@linux-foundation.org>
MIME-Version: 1.0
Subject: Re: [patch 1/4] Make the per cpu reserve configurable
References: <20080919145859.062069850@quilx.com>	<20080919145928.322062135@quilx.com> <20080920125546.d6d7b42e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080920125546.d6d7b42e.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

KAMEZAWA Hiroyuki wrote:
> Is this PERCPU_MODULE_RESERVE default size is fixex to 8192 bytes
> both on 32bit-arch and 64bit-arch ?
>   
Yes.
> How about enlarging this to twice on 64bit arch now ?
>
> sorry for noise.
No actually a good idea to discuss the limit here. Maybe use 10000 for 32 bit and 15000 for 64 bit? Many percpu variables are counters that may be integers.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
