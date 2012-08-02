Return-Path: <owner-linux-mm@kvack.org>
Date: Wed, 1 Aug 2012 23:03:15 -0400
From: Benjamin LaHaise <bcrl@kvack.org>
Subject: Re: BOUNCE linux-mm@kvack.org: Header field too long (>2048) Was: [RFC PATCH 05/23 V2] mm,migrate: use N_MEMORY instead N_HIGH_MEMORY
Message-ID: <20120802030315.GD31604@kvack.org>
References: <20120802025250.AEF8E6B005A@kanga.kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120802025250.AEF8E6B005A@kanga.kvack.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Cc: linux-mm@kvack.org

Hello Lai,

On Wed, Aug 01, 2012 at 10:52:50PM -0400, owner-linux-mm@kvack.org wrote:
> Cc: Paul Menage <paul@paulmenage.org>, Rob Landley <rob@landley.net>,
>         Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>,
>         "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
>         Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
>         Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>,
>         Balbir Singh <bsingharora@gmail.com>,
>         KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,
>         Tejun Heo <tj@kernel.org>, Li Zefan <lizefan@huawei.com>,
>         Christoph Lameter <cl@linux-foundation.org>,
>         Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>,
>         Jarkko Sakkinen <jarkko.sakkinen@intel.com>,
>         Matt Fleming <matt.fleming@intel.com>,
>         Andrew Morton <akpm@linux-foundation.org>,
>         Yinghai Lu <yinghai@kernel.org>, David Rientjes <rientjes@google.com>,
>         Bjorn Helgaas <bhelgaas@google.com>,
>         Wanlong Gao <gaowanlong@cn.fujitsu.com>,
>         Petr Holasek <pholasek@redhat.com>, Djalal Harouni <tixxdz@opendz.org>,
>         Jiri Kosina <jkosina@suse.cz>, Laura Vasilescu <laura@rosedu.org>,
>         WANG Cong <xiyou.wangcong@gmail.com>, Hugh Dickins <hughd@google.com>,
>         Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>,
>         Konstantin Khlebnikov <khlebnikov@openvz.org>,
>         Sam Ravnborg <sam@ravnborg.org>,
>         Paul Gortmaker <paul.gortmaker@windriver.com>,
>         Rusty Russell <rusty@rustcorp.com.au>,
>         Peter Zijlstra <a.p.zijlstra@chello.nl>,
>         Jim Cromie <jim.cromie@gmail.com>, Pawel Moll <pawel.moll@arm.com>,
>         Henrique de Moraes Holschuh <ibm-acpi@hmh.eng.br>,
>         Oleg Nesterov <oleg@redhat.com>,
>         Dan Magenheimer <dan.magenheimer@oracle.com>,
>         Michal Nazarewicz <mina86@mina86.com>, Mel Gorman <mgorman@suse.de>,
>         Hillf Danton <dhillf@gmail.com>,
>         Gavin Shan <shangw@linux.vnet.ibm.com>,
>         Wen Congyang <wency@cn.fujitsu.com>, Rik van Riel <riel@redhat.com>,
>         KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>,
>         Wang Sheng-Hui <shhuiw@gmail.com>, Minchan Kim <minchan@kernel.org>,
>         linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
>         linux-mm@kvack.org, cgroups@vger.kernel.org,
>         containers@lists.linux-foundation.org,
>         Lai Jiangshan <laijs@cn.fujitsu.com>
> Subject: [RFC PATCH 05/23 V2] mm,migrate: use N_MEMORY instead N_HIGH_MEMORY

A Cc list that is more than 2048 bytes in length is completely unreasonable, 
so I'm not planning on raising the length of the headers for this kind of 
stupidity.  If your Cc list is this long, you're doing something wrong.  Let 
the mailing lists deliver your email to 90% of the people on the Cc list, 
as that's what they're here for.

		-ben

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
