Date: Thu, 5 Feb 2004 16:07:55 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.2-mm1 aka "Geriatric Wombat" DIO read race still fails
Message-Id: <20040205160755.25583627.akpm@osdl.org>
In-Reply-To: <1076023899.7182.97.camel@ibm-c.pdx.osdl.net>
References: <20040205014405.5a2cf529.akpm@osdl.org>
	<1076023899.7182.97.camel@ibm-c.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel McNeil <daniel@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-aio@kvack.org
List-ID: <linux-mm.kvack.org>

Daniel McNeil <daniel@osdl.org> wrote:
>
> Andrew,
> 
> I tested 2.6.2-mm1 on an 8-proc running 6 copies of the read_under
> test and all 6 read_under tests saw uninitialized data in less than 5
> minutes. :(

The performance implications of synchronising behind kjournald writes for
normal non-blocking writeback are bad.  Can you detail what you now think
is the failure mechanism?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
