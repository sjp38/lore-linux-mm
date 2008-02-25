Date: Mon, 25 Feb 2008 10:56:06 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Memory Resource Controller use strstrip while parsing
 arguments
Message-Id: <20080225105606.bcab215e.akpm@linux-foundation.org>
In-Reply-To: <20080225182746.9512.21582.sendpatchset@localhost.localdomain>
References: <20080225182746.9512.21582.sendpatchset@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Hugh Dickins <hugh@veritas.com>, Sudhir Kumar <skumar@linux.vnet.ibm.com>, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, Paul Menage <menage@google.com>, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, taka@valinux.co.jp, linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Pavel Emelianov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 25 Feb 2008 23:57:46 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> The memory controller has a requirement that while writing values, we need
> to use echo -n. This patch fixes the problem and makes the UI more consistent.

that's a decent improvement ;)

btw, could I ask that you, Paul and others who work on this and cgroups
have a think about a ./MAINTAINERS update?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
