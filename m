Date: Sat, 24 Jun 2006 16:46:32 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Patch [4/4] x86_64 sparsmem add- acpi fixup take 2
 motherboard.c
Message-Id: <20060624164632.cae78fab.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1151114777.7094.53.camel@keithlap>
References: <1151114777.7094.53.camel@keithlap>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kmannth@us.ibm.com
Cc: lhms-devel@lists.sourceforge.net, linux-mm@kvack.org, haveblue@us.ibm.com, acpi@linux.intel.com
List-ID: <linux-mm.kvack.org>

On Fri, 23 Jun 2006 19:06:17 -0700
keith mannthey <kmannth@us.ibm.com> wrote:

> I am not sure what the correct solution to this problem is. Built
> against 2.6.17-mm1 but should apply with fuzz just about anywhere. 
> 
> Signed-off-by:  Keith Mannthey <kmannth@us.ibm.com>
> 

What I can say now is..
1. In this case, a driver for _CID is attached before a driver for _HID
2. I don't find description in acpi SPEC,  "how to handle a device which has 
   _HID and _CID, and drivers for them are different from each other"
3. maybe memory device shouldn't be described as compatible device of mother 
   board.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
