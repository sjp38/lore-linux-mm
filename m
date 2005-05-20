From: Wolfgang Wander <wwc@rentec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17037.56393.789430.265404@gargle.gargle.HOWL>
Date: Fri, 20 May 2005 08:47:05 -0400
Subject: RE: [PATCH] Avoiding mmap fragmentation - clean rev
In-Reply-To: <200505200214.j4K2Ecg06778@unix-os.sc.intel.com>
References: <200505200214.j4K2Ecg06778@unix-os.sc.intel.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Chen, Kenneth W" <kenneth.w.chen@intel.com>
Cc: 'Andrew Morton' <akpm@osdl.org>, 'Wolfgang Wander' <wwc@rentec.com>, herve@elma.fr, mingo@elte.hu, arjanv@redhat.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Chen, Kenneth W writes:
 > Chen, Kenneth W wrote on Thursday, May 19, 2005 7:02 PM
 > > Oh well, I guess we have to take a performance hit here in favor of
 > > functionality.  Though this is a problem specific to 32-bit address
 > > space, please don't unnecessarily penalize 64-bit arch.  If Andrew is
 > > going to take Wolfgang's patch, then we should minimally take the
 > > following patch.  This patch revert changes made in arch/ia64 and make
 > > x86_64 to use alternate cache algorithm for 32-bit app.

Great! Makes more than perfect sense in the 64bit world.

            Wolfgang
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
