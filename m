Date: Wed, 25 May 2005 23:48:24 -0700
From: "Martin J. Bligh" <mbligh@mbligh.org>
Reply-To: "Martin J. Bligh" <mbligh@mbligh.org>
Subject: Re: NUMA aware slab allocator V3
Message-ID: <179780000.1117090103@[10.10.2.4]>
In-Reply-To: <Pine.LNX.4.62.0505251402090.15286@graphe.net>
References: <Pine.LNX.4.58.0505110816020.22655@schroedinger.engr.sgi.com> <Pine.LNX.4.62.0505161046430.1653@schroedinger.engr.sgi.com> <714210000.1116266915@flay> <200505161410.43382.jbarnes@virtuousgeek.org> <740100000.1116278461@flay>  <Pine.LNX.4.62.0505161713130.21512@graphe.net><1116289613.26955.14.camel@localhost> <428A800D.8050902@us.ibm.com><Pine.LNX.4.62.0505171648370.17681@graphe.net> <428B7B16.10204@us.ibm.com><Pine.LNX.4.62.0505181046320.20978@schroedinger.engr.sgi.com><428BB05B.6090704@us.ibm.com> <Pine.LNX.4.62.0505181439080.10598@graphe.net><Pine.LNX.4.62.0505182105310.17811@graphe.net> <428E3497.3080406@us.ibm.com><Pine.LNX.4.62.0505201210460.390@graphe.net> <428E56EE.4050400@us.ibm.com><Pine.LNX.4.62.0505241436460.3878@graphe.net>
 <4293B292.6010301@us.ibm.com><Pine.LNX.4.62.0505242221340.7191@graphe.net> <4294C39B.1040401@us.ibm.com> <Pine.LNX.4.62.0505251402090.15286@graphe.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <christoph@lameter.com>, Matthew Dobson <colpatch@us.ibm.com>
Cc: Andrew Morton <akpm@osdl.org>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>


--Christoph Lameter <christoph@lameter.com> wrote (on Wednesday, May 25, 2005 14:03:06 -0700):

> On Wed, 25 May 2005, Matthew Dobson wrote:
> 
>> > Umm.. How does it fail? Any relationship to the slab allocator?
>> 
>> It dies really early om my x86 box.  I'm not 100% sure that it is b/c of
>> your patches, since it dies so early I get nothing on the console.  Grub
>> tells me it's loading the kernel image then....  nothing.
> 
> Hmmm. Do you have an emulator? For IA32 and IA64 we have something that 
> simulates a boot up sequence and can tell us what is going on.

Turning on early printk is probably easier. Not that it seems to work nearly
as early as some of hte other implementations we had, but still.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
