From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm] Add an owner to the mm_struct (v5)
Date: Thu, 03 Apr 2008 11:58:52 +0530
Message-ID: <47F47924.5050905@linux.vnet.ibm.com>
References: <20080403055901.31796.41411.sendpatchset@localhost.localdomain> <47F476FE.6040800@cn.fujitsu.com>
Reply-To: balbir@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761438AbYDCG3g@vger.kernel.org>
In-Reply-To: <47F476FE.6040800@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: Paul Menage <menage@google.com>, Pavel Emelianov <xemul@openvz.org>, Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-Id: linux-mm.kvack.org

> 
> #ifdef CONFIG_MM_OWNER
> 	.owner		= &init_task,
> #endif
> 
> Otherwise building broken with CONFIG_MM_OWNER disabled.

Good catch. Let me fix it and send v6

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL
