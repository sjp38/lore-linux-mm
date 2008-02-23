Date: Sat, 23 Feb 2008 00:04:26 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] ResCounter: Use read_uint in memory controller
Message-Id: <20080223000426.adf5c75a.akpm@linux-foundation.org>
In-Reply-To: <47BE4FB5.5040902@linux.vnet.ibm.com>
References: <20080221203518.544461000@menage.corp.google.com>
	<20080221205525.349180000@menage.corp.google.com>
	<47BE4FB5.5040902@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: menage@google.com, xemul@openvz.org, balbir@in.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, 22 Feb 2008 09:59:41 +0530 Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> menage@google.com wrote:
> > Update the memory controller to use read_uint for its
> > limit/usage/failcnt control files, calling the new
> > res_counter_read_uint() function.
> > 
> > Signed-off-by: Paul Menage <menage@google.com>
> > 
> 
> Hi, Paul,
> 
> Looks good, except for the name uint(), can we make it u64(). Integers are 32
> bit on both ILP32 and LP64, but we really read/write 64 bit values.
> 

yup, I agree.  Even though I don't know what ILP32 and LP64 are ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
