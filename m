Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 1FA9F6B0004
	for <linux-mm@kvack.org>; Mon, 21 Jan 2013 06:12:11 -0500 (EST)
Date: Mon, 21 Jan 2013 12:12:06 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: memcg: cat: memory.memsw.* : Operation not supported
Message-ID: <20130121111206.GG7798@dhcp22.suse.cz>
References: <4FEE7665.6020409@jp.fujitsu.com>
 <389106003.8637801.1358757547754.JavaMail.root@redhat.com>
 <20130121105624.GF7798@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130121105624.GF7798@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zhouping Liu <zliu@redhat.com>
Cc: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Li Zefan <lizefan@huawei.com>, CAI Qian <caiqian@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>

And we can put another clean up patch on top of the fix:
---
