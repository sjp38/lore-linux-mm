Message-Id: <200511232333.jANNX9g23967@unix-os.sc.intel.com>
From: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Subject: RE: Kernel BUG at mm/rmap.c:491
Date: Wed, 23 Nov 2005 15:33:09 -0800
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
In-Reply-To: <cone.1132788250.534735.25446.501@kolivas.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: 'Con Kolivas' <con@kolivas.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Con Kolivas wrote on Wednesday, November 23, 2005 3:24 PM
> Chen, Kenneth W writes:
> 
> > Has people seen this BUG_ON before?  On 2.6.15-rc2, x86-64.
> > 
> > Pid: 16500, comm: cc1 Tainted: G    B 2.6.15-rc2 #3
> > 
> > Pid: 16651, comm: sh Tainted: G    B 2.6.15-rc2 #3
> 
>                        ^^^^^^^^^^
> 
> Please try to reproduce it without proprietary binary modules linked in.


???, I'm not using any modules at all.

[albat]$ /sbin/lsmod
Module                  Size  Used by
[albat]$ 


Also, isn't it 'P' indicate proprietary module, not 'G'?
line 159: kernel/panic.c:

        snprintf(buf, sizeof(buf), "Tainted: %c%c%c%c%c%c",
                tainted & TAINT_PROPRIETARY_MODULE ? 'P' : 'G',

- Ken

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
