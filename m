Date: Tue, 19 Dec 2006 09:16:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] Fix sparsemem on Cell
Message-Id: <20061219091625.43d45893.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1166483780.8648.26.camel@localhost.localdomain>
References: <20061215165335.61D9F775@localhost.localdomain>
	<20061215114536.dc5c93af.akpm@osdl.org>
	<20061216170353.2dfa27b1.kamezawa.hiroyu@jp.fujitsu.com>
	<200612182354.47685.arnd@arndb.de>
	<1166483780.8648.26.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: arnd@arndb.de, linuxppc-dev@ozlabs.org, akpm@osdl.org, kmannth@us.ibm.com, linux-kernel@vger.kernel.org, hch@infradead.org, linux-mm@kvack.org, paulus@samba.org, mkravetz@us.ibm.com, gone@us.ibm.com, cbe-oss-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

On Mon, 18 Dec 2006 15:16:20 -0800
Dave Hansen <haveblue@us.ibm.com> wrote:

> enum context
> {
>         EARLY,
>         HOTPLUG
> };
I like this :)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
