Date: Fri, 2 May 2003 13:34:05 -0700
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.68-mm4
Message-Id: <20030502133405.57207c48.akpm@digeo.com>
In-Reply-To: <1051905879.2166.34.camel@spc9.esa.lanl.gov>
References: <20030502020149.1ec3e54f.akpm@digeo.com>
	<1051905879.2166.34.camel@spc9.esa.lanl.gov>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Cole <elenstev@mesatop.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Steven Cole <elenstev@mesatop.com> wrote:
>
> For what it's worth, kexec has worked for me on the following
> two systems.
> ...
> 00:03.0 Ethernet controller: Intel Corp. 82557/8/9 [Ethernet Pro 100] (rev 08)

Are you using eepro100 or e100?  I found that e100 failed to bring up the
interface on restart ("failed selftest"), but eepro100 was OK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
