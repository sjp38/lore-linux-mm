Date: Sat, 1 Mar 2003 20:31:09 +1100
From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH 2.5.62-mm3] objrmap fix for X
Message-ID: <20030301093109.GF2606@krispykreme>
References: <20030223230023.365782f3.akpm@digeo.com> <40780000.1046240068@[10.10.2.4]> <14910000.1046281932@[10.10.2.4]>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <14910000.1046281932@[10.10.2.4]>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Dave McCracken <dmccr@us.ibm.com>, Andrew Morton <akpm@digeo.com>, zilvinas@gemtek.lt, helgehaf@aitel.hist.no, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Pah. Debian stealth-upgraded me to gcc 3.2 ... no wonder it's slow as a
> dog. So your patch is stable, and works just fine. Sorry,

Yep, gcc-2.95 -> gcc-3.2 dropped SDET results by about 10% on my ppc64
boxes :(

Anton
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
