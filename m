Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 385376B004F
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 03:46:36 -0500 (EST)
Message-ID: <496DA63A.8010404@cn.fujitsu.com>
Date: Wed, 14 Jan 2009 16:45:46 +0800
From: Li Zefan <lizf@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: fix return value of mem_cgroup_hierarchy_write()
References: <496D9E0C.4060806@cn.fujitsu.com> <20090114083835.GL27129@balbir.in.ibm.com>
In-Reply-To: <20090114083835.GL27129@balbir.in.ibm.com>
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Paul Menage <menage@google.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Balbir Singh wrote:
> * Li Zefan <lizf@cn.fujitsu.com> [2009-01-14 16:10:52]:
> 
>> When there are sub-dirs, writing to memory.use_hierarchy returns -EBUSY,
>> this doesn't seem to fit the meaning of EBUSY, and is inconsistent with
>> memory.swappiness, which returns -EINVAL in this case.
>>
>> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>
> 
> The patch does much more than the changelog says. The reason for EBUSY
> is that the group is in use due to children or existing references and
> tasks. I think EBUSY is the correct error code to return.
> 

Sounds reasonable for me. Thanks.

Regards
Li Zefan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
