Received: from nypop.smtp.stsn.com ([127.0.0.1])
 by s-utl01-nypop.stsn.com (SAVSMTP 3.1.0.29) with SMTP id M2005021207343301680
 for <linux-mm@kvack.org>; Sat, 12 Feb 2005 07:34:33 -0500
Subject: Re: [RFC 2.6.11-rc2-mm2 7/7] mm: manual page migration --
	sys_page_migrate
From: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <20050212032620.18524.15178.29731@tomahawk.engr.sgi.com>
References: <20050212032535.18524.12046.26397@tomahawk.engr.sgi.com>
	 <20050212032620.18524.15178.29731@tomahawk.engr.sgi.com>
Content-Type: text/plain
Date: Sat, 12 Feb 2005 07:34:32 -0500
Message-Id: <1108211672.4056.10.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, Hugh DIckins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Dave Hansen <haveblue@us.ibm.com>, Marcello Tosatti <marcello@cyclades.com>, Ray Bryant <raybry@austin.rr.com>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2005-02-11 at 19:26 -0800, Ray Bryant wrote:
> This patch introduces the sys_page_migrate() system call:
> 
> sys_page_migrate(pid, va_start, va_end, count, old_nodes, new_nodes);

are you really sure you want to expose nodes to userspace via an ABI
this solid and never changing? To me that feels somewhat like too much
of an internal thing to expose that will mean that those internals are
now set in stone due to the interface...


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
