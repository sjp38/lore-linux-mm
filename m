Date: Tue, 03 Feb 2004 14:26:19 -0800
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: Active Memory Defragmentation: Our implementation & problems
Message-ID: <6020000.1075847179@flay>
In-Reply-To: <1075843615.28252.17.camel@nighthawk>
References: <20040203044651.47686.qmail@web9705.mail.yahoo.com> <1075843615.28252.17.camel@nighthawk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>, Alok Mooley <rangdi@yahoo.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

> I'll stop there for now.  There seems to be a lot of code in the file
> that's one-off from current kernel code.  I think a close examination of
> currently available kernel functions could drasticly reduce the size of
> your module.  

Preferably to 0 ... this should be part of the core kernel, not a module.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
