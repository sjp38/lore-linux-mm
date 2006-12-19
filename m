From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] Fix sparsemem on Cell
Date: Tue, 19 Dec 2006 09:59:45 +0100
References: <20061215165335.61D9F775@localhost.localdomain> <200612182354.47685.arnd@arndb.de> <1166483780.8648.26.camel@localhost.localdomain>
In-Reply-To: <1166483780.8648.26.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 8BIT
Content-Disposition: inline
Message-Id: <200612190959.47344.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: linuxppc-dev@ozlabs.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@osdl.org>, kmannth@us.ibm.com, linux-kernel@vger.kernel.org, hch@infradead.org, linux-mm@kvack.org, paulus@samba.org, mkravetz@us.ibm.com, gone@us.ibm.com, cbe-oss-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

On Tuesday 19 December 2006 00:16, Dave Hansen wrote:
> How about an enum, or a pair of #defines?
> 
> enum context
> {
>         EARLY,
>         HOTPLUG
> };

Sounds good, but since this is in a global header file, it needs
to be in an appropriate name space, like

enum memmap_context {
	MEMMAP_EARLY,
	MEMMAP_HOTPLUG,
};

	Arnd <><

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
