Date: Thu, 1 May 2008 18:14:52 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch] SLQB v2
In-Reply-To: <20080502004325.GA30768@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0805011813180.13527@schroedinger.engr.sgi.com>
References: <20080410193137.GB9482@wotan.suse.de> <20080415034407.GA9120@ubuntu>
 <20080501015418.GC15179@wotan.suse.de> <Pine.LNX.4.64.0805011226410.8738@schroedinger.engr.sgi.com>
 <20080502004325.GA30768@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: "Ahmed S. Darwish" <darwish.07@gmail.com>, Linux Memory Management List <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, 2 May 2008, Nick Piggin wrote:

> If you are not debugging sl?b.c code/pages, then why would you want to see
> what those fields are?

Because you are f.e. inspecting a core dump and want to see why certain 
fields have certain values to verify that the structures were not 
overwrittten or corrupted etc.


 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
