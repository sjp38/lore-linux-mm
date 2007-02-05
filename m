Date: Mon, 5 Feb 2007 13:36:11 +0100
From: "Joerg Roedel" <joerg.roedel@amd.com>
Subject: Re: your mail
Message-ID: <20070205123611.GI8804@amd.com>
References: <1131.86.55.168.2.1170690089.squirrel@mail.thinknet.ro>
MIME-Version: 1.0
In-Reply-To: <1131.86.55.168.2.1170690089.squirrel@mail.thinknet.ro>
Content-Type: text/plain;
 charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: logic@thinknet.ro
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 05, 2007 at 05:41:29PM +0200, logic@thinknet.ro wrote:
> Good morning,
> 
> I am experiencing a bug i think. I am running a 2.6.19.2 kernel on a 3Ghz
> Intel with HT activated, 1 gb ram, and noname motherboard. Here is the
> output of the hang:

Hmm, this seems to be the same issue as in [1] and [2]. A page that is
assumed to belong to the slab but is not longer marked as a slab page.
Could this be a bug in the memory management?

Joerg

[1] http://lkml.org/lkml/2007/2/4/77
[2] http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=406477

-- 
Joerg Roedel
Operating System Research Center
AMD Saxony LLC & Co. KG

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
