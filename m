Subject: Re: 2.6.0-test9-mm2 - AIO tests still gets slab corruption
From: Daniel McNeil <daniel@osdl.org>
In-Reply-To: <20031104225544.0773904f.akpm@osdl.org>
References: <20031104225544.0773904f.akpm@osdl.org>
Content-Type: text/plain
Message-Id: <1068505605.2042.11.camel@ibm-c.pdx.osdl.net>
Mime-Version: 1.0
Date: 10 Nov 2003 15:06:45 -0800
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, Suparna Bhattacharya <suparna@in.ibm.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, "linux-aio@kvack.org" <linux-aio@kvack.org>
List-ID: <linux-mm.kvack.org>

Andrew,

test9-mm2 is still getting slab corruption with AIO:

Maximal retry count.  Bytes done 0
Slab corruption: start=dc70f91c, expend=dc70f9eb, problemat=dc70f91c
Last user: [<c0192fa3>](__aio_put_req+0xbf/0x200)
Data: 00 01 10 00 00 02 20 00 *********6C ******************************A5
Next: 71 F0 2C .A3 2F 19 C0 71 F0 2C .********************
slab error in check_poison_obj(): cache `kiocb': object was modified after freeing

With suparna's retry-based-aio-dio patch, there are no kernel messages
and the tests do not see any uninitialized data.

Any reason not to add suparna's patch to -mm to fix these problems?

Thanks,

Daniel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
