Date: Fri, 30 Jan 2004 14:00:24 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.2-rc2-mm2
Message-Id: <20040130140024.4b409335.akpm@osdl.org>
In-Reply-To: <20040130211256.GZ9155@sun.com>
References: <20040130014108.09c964fd.akpm@osdl.org>
	<1075489136.5995.30.camel@moria.arnor.net>
	<200401302007.26333.thomas.schlichter@web.de>
	<1075490624.4272.7.camel@laptop.fenrus.com>
	<20040130114701.18aec4e8.akpm@osdl.org>
	<20040130201731.GY9155@sun.com>
	<20040130123301.70009427.akpm@osdl.org>
	<20040130211256.GZ9155@sun.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: thockin@sun.com
Cc: arjanv@redhat.com, thomas.schlichter@web.de, thoffman@arnor.net, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Tim Hockin <thockin@sun.com> wrote:
>
> In fact, here is a rough cut (would need a coupel exported syms, too).  The
> lack of any way to handle errors bothers me.  printk and fail?  yeesh.

Seems to be a good way to go.  It doesn't seem likely that any other parts
of the kernel will want to be setting the group ownership in this way.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
