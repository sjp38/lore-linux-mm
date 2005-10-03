From: David Lang <david.lang@digitalinsight.com>
In-Reply-To: dlang@dlang.diginsite.com
References: dlang@dlang.diginsite.com
Date: Mon, 3 Oct 2005 08:03:44 -0700 (PDT)
Subject: Re: [PATCH 00/07][RFC] i386: NUMA emulation
In-Reply-To: <79580000.1128351582@[10.10.2.4]>
Message-ID: <Pine.LNX.4.62.0510030802090.11541@qynat.qvtvafvgr.pbz>
References: <20050930073232.10631.63786.sendpatchset@cherry.local><1128093825.6145.26.camel@localhost><aec7e5c30510021908la86daf9je0584fb0107f833a@mail.gmail.com><Pine.LNX.4.62.0510030031170.11095@qynat.qvtvafvgr.pbz><aec7e5c30510030302u8186cfer642c7b9337613de@mail.gmail.com>
 <Pine.LNX.4.62.0510030628150.11541@qynat.qvtvafvgr.pbz> <79580000.1128351582@[10.10.2.4]>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@mbligh.org>
Cc: Magnus Damm <magnus.damm@gmail.com>, Dave Hansen <haveblue@us.ibm.com>, Magnus Damm <magnus@valinux.co.jp>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, 3 Oct 2005, Martin J. Bligh wrote:

> But that's not the same at all! ;-) PAE memory is the same speed as
> the other stuff. You just have a 3rd level of pagetables for everything.
> One could (correctly) argue it made *all* memory slower, but it does so
> in a uniform fashion.

is it? I've seen during the memory self-test at boot that machines slow 
down noticably as they pass the 4G mark.

David Lang

-- 
There are two ways of constructing a software design. One way is to make it so simple that there are obviously no deficiencies. And the other way is to make it so complicated that there are no obvious deficiencies.
  -- C.A.R. Hoare

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
