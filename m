Subject: Re: 2.6.2-mm1 aka "Geriatric Wombat" DIO read race still fails
From: Daniel McNeil <daniel@osdl.org>
In-Reply-To: <20040205014405.5a2cf529.akpm@osdl.org>
References: <20040205014405.5a2cf529.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1076023899.7182.97.camel@ibm-c.pdx.osdl.net>
Mime-Version: 1.0
Date: 05 Feb 2004 15:31:39 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "linux-aio@kvack.org" <linux-aio@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrew,

I tested 2.6.2-mm1 on an 8-proc running 6 copies of the read_under
test and all 6 read_under tests saw uninitialized data in less than 5
minutes. :(

Daniel



On Thu, 2004-02-05 at 01:44, Andrew Morton wrote:
> ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.2/2.6.2-mm1/

> 
> O_DIRECT-ll_rw_block-vs-block_write_full_page-fix.patch
>   Fix race between ll_rw_block() and block_write_full_page()
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
