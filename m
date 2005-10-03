Date: Mon, 03 Oct 2005 07:59:43 -0700
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: [PATCH 00/07][RFC] i386: NUMA emulation
Message-ID: <79580000.1128351582@[10.10.2.4]>
In-Reply-To: <Pine.LNX.4.62.0510030628150.11541@qynat.qvtvafvgr.pbz>
References: <20050930073232.10631.63786.sendpatchset@cherry.local><1128093825.6145.26.camel@localhost><aec7e5c30510021908la86daf9je0584fb0107f833a@mail.gmail.com><Pine.LNX.4.62.0510030031170.11095@qynat.qvtvafvgr.pbz><aec7e5c30510030302u8186cfer642c7b9337613de@mail.gmail.com> <Pine.LNX.4.62.0510030628150.11541@qynat.qvtvafvgr.pbz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Lang <dlang@digitalinsight.com>, Magnus Damm <magnus.damm@gmail.com>
Cc: Dave Hansen <haveblue@us.ibm.com>, Magnus Damm <magnus@valinux.co.jp>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> if nothing else preferential use of 'local' (non PAE) memory over 
> 'remote' (PAE) memory for programs, while still useing it all as needed.

Why would you want to do that? ;-)

> this may be done already, but this type of difference between the access 
> speed of different chunks of ram seems to be exactly the type of thing 
> that the NUMA code solves the general case for.

It is! 

> I'm thinking that it 
> may end up simplifying things if the same general-purpose logic will 
> work for the specific case of PAE instead of it being hard coded as 
> a special case.

But that's not the same at all! ;-) PAE memory is the same speed as
the other stuff. You just have a 3rd level of pagetables for everything.
One could (correctly) argue it made *all* memory slower, but it does so
in a uniform fashion.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
