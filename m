Message-ID: <3DA5CD19.80603@us.ibm.com>
Date: Thu, 10 Oct 2002 11:55:21 -0700
From: Matthew Dobson <colpatch@us.ibm.com>
Reply-To: colpatch@us.ibm.com
MIME-Version: 1.0
Subject: Re: [rfc][patch] Memory Binding API v0.3 2.5.41
References: <3DA4D3E4.6080401@us.ibm.com> <1034240403.1745.0.camel@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjanv@redhat.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, LSE <lse-tech@lists.sourceforge.net>, Andrew Morton <akpm@zip.com.au>, Martin Bligh <mjbligh@us.ibm.com>, Michael Hohnbaum <hohnbaum@us.ibm.com>
List-ID: <linux-mm.kvack.org>

Arjan van de Ven wrote:
> On Thu, 2002-10-10 at 03:12, Matthew Dobson wrote:
> 
>>Greetings & Salutations,
>>	Here's a wonderful patch that I know you're all dying for...  Memory 
>>Binding!  It works just like CPU Affinity (binding) except that it binds 
>>a processes memory allocations (just buddy allocator for now) to 
>>specific memory blocks.
> 
> If the VM works right just doing CPU binding ought to be enough, surely?
You'll have to look at the response I wrote to Andrew's question along 
the same
lines...  This patch is for processes who feel that the VM *isn't* doing
quite what they want, and want different behavior.

Cheers!

-Matt

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
