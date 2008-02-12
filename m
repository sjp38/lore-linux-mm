Date: Tue, 12 Feb 2008 01:44:44 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 7/8] Do not recompute msgmni anymore if explicitely set
 by user
Message-Id: <20080212014444.8bc3791b.akpm@linux-foundation.org>
In-Reply-To: <47B167AF.6010008@bull.net>
References: <20080211141646.948191000@bull.net>
	<20080211141816.094061000@bull.net>
	<20080211122408.5008902f.akpm@linux-foundation.org>
	<47B167AF.6010008@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nadia Derbey <Nadia.Derbey@bull.net>
Cc: linux-kernel@vger.kernel.org, y-goto@jp.fujitsu.com, linux-mm@kvack.org, containers@lists.linux-foundation.org, matthltc@us.ibm.com, cmm@us.ibm.com
List-ID: <linux-mm.kvack.org>

On Tue, 12 Feb 2008 10:32:31 +0100 Nadia Derbey <Nadia.Derbey@bull.net> wrote:

> it builds fine, modulo some changes in ipv4 and ipv6 (see attached patch 
> - didn't find it in the hot fixes).

OK, thanks for checking.  Did you confirm that we don't have unneeded code
in vmlinux when CONFIG_PROCFS=n?  I guess before-and-after comparison of
the size(1) output would tell us.

Those networking build problems appear to have already been fixed.

In future, please quote the compiler error output in the changelog when
sending build fixes or warning fixes, thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
