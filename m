Content-Type: text/plain;
  charset="iso-8859-1"
From: Badari Pulavarty <pbadari@us.ibm.com>
Subject: Re: 2.6.2-mm1 aka "Geriatric Wombat" DIO read race still fails
Date: Thu, 5 Feb 2004 15:58:08 -0800
References: <20040205014405.5a2cf529.akpm@osdl.org> <1076023899.7182.97.camel@ibm-c.pdx.osdl.net>
In-Reply-To: <1076023899.7182.97.camel@ibm-c.pdx.osdl.net>
MIME-Version: 1.0
Content-Transfer-Encoding: 8BIT
Message-Id: <200402051558.08927.pbadari@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Daniel McNeil <daniel@osdl.org>, Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "linux-aio@kvack.org" <linux-aio@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thursday 05 February 2004 03:31 pm, Daniel McNeil wrote:
> Andrew,
>
> I tested 2.6.2-mm1 on an 8-proc running 6 copies of the read_under
> test and all 6 read_under tests saw uninitialized data in less than 5
> minutes. :(
>
> Daniel

Daniel,

Same here... Just FYI, I am running with your original patch and
not failed so far (2 hours..) Normally, I see the problem in 15 min or so.

Thanks,
Badari
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
