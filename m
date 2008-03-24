Date: Mon, 24 Mar 2008 12:29:47 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [00/14] Virtual Compound Page Support V3
In-Reply-To: <Pine.LNX.4.64.0803241129100.3002@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0803241228410.3959@schroedinger.engr.sgi.com>
References: <20080321061703.921169367@sgi.com> <20080322114043.17833ab4@laptopd505.fenrus.org>
 <Pine.LNX.4.64.0803241129100.3002@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Arjan van de Ven <arjan@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On the other hand: The conversion of vmalloc to vcompound_alloc will 
reduce the amount of virtually mapped space needed. Doing that to 
alloc_large_system_hash() etc may help there.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
