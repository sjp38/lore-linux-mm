Date: Sat, 12 Feb 2005 15:48:35 +0100
From: Andi Kleen <ak@suse.de>
Subject: Re: [RFC 2.6.11-rc2-mm2 7/7] mm: manual page migration -- sys_page_migrate
Message-ID: <20050212144835.GC16075@wotan.suse.de>
References: <20050212032535.18524.12046.26397@tomahawk.engr.sgi.com> <20050212032620.18524.15178.29731@tomahawk.engr.sgi.com> <1108211672.4056.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1108211672.4056.10.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: Ray Bryant <raybry@sgi.com>, Hirokazu Takahashi <taka@valinux.co.jp>, Hugh DIckins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Dave Hansen <haveblue@us.ibm.com>, Marcello Tosatti <marcello@cyclades.com>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat, Feb 12, 2005 at 07:34:32AM -0500, Arjan van de Ven wrote:
> On Fri, 2005-02-11 at 19:26 -0800, Ray Bryant wrote:
> > This patch introduces the sys_page_migrate() system call:
> > 
> > sys_page_migrate(pid, va_start, va_end, count, old_nodes, new_nodes);
> 
> are you really sure you want to expose nodes to userspace via an ABI
> this solid and never changing? To me that feels somewhat like too much
> of an internal thing to expose that will mean that those internals are
> now set in stone due to the interface...

They're already exposed through mbind/set_mempolicy/get_mempolicy and sysfs
of course.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
