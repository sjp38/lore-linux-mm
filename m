Date: Sat, 23 Feb 2008 00:04:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/2] cgroup map files: Add a key/value map file type to
 cgroups
Message-Id: <20080223000413.4b10db88.akpm@linux-foundation.org>
In-Reply-To: <20080221212854.408662000@menage.corp.google.com>
References: <20080221212854.408662000@menage.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: menage@google.com
Cc: kamezawa.hiroyu@jp.fujitsu.com, yamamoto@valinux.co.jp, linux-kernel@vger.kernel.org, linux-mm@kvack.org, balbir@in.ibm.com, xemul@openvz.org
List-ID: <linux-mm.kvack.org>

On Thu, 21 Feb 2008 13:28:54 -0800 menage@google.com wrote:

> These patches add a new cgroup control file output type - a map from
> strings to u64 values - and make use of it for the memory controller
> "stat" file.

Can we document the moderately obscure kernel->userspace interface
somewhere please?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
