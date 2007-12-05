Date: Wed, 5 Dec 2007 09:44:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][for -mm] memory controller enhancements for reclaiming
 take2 [0/8] introduction
Message-Id: <20071205094420.9967bab8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <47556341.4090101@linux.vnet.ibm.com>
References: <20071203183355.0061ddeb.kamezawa.hiroyu@jp.fujitsu.com>
	<47556341.4090101@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "containers@lists.osdl.org" <containers@lists.osdl.org>, Andrew Morton <akpm@linux-foundation.org>, "yamamoto@valinux.co.jp" <yamamoto@valinux.co.jp>, "riel@redhat.com" <riel@redhat.com>, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Tue, 04 Dec 2007 19:55:05 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> KAMEZAWA-San, what happens if we use a little less aggressive set of
> watermarks, something like
> 
> 700/300
> 
will test today. you mean low=300M, high=700M, limit=800M case ?

> Can we keep the defaults something close to what each zone uses?
> pages_low, pages_high and pages_min.
> 
After review of Pavel-san, "don't define *default* value" style is used here.
If we use default value, we'll have to detect "we should adjust high/low
watermarks when the limit changes."

That will complicate things and may crash the system administrators policy.
It's not havey work to adjust high/low limit to sutitable value (which was
defined against the workload by system admin) at setting limit.

Thanks,
-kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
