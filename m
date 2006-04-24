From: Andi Kleen <ak@suse.de>
Subject: Re: [patch 1/8] Page host virtual assist: unused / free pages.
Date: Mon, 24 Apr 2006 17:06:26 +0200
References: <20060424123423.GB15817@skybase> <200604241649.24792.ak@suse.de> <1145890749.5241.12.camel@localhost>
In-Reply-To: <1145890749.5241.12.camel@localhost>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200604241706.27221.ak@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: schwidefsky@de.ibm.com
Cc: linux-mm@kvack.org, akpm@osdl.org, frankeh@watson.ibm.com, rhim@cc.gatech.edu
List-ID: <linux-mm.kvack.org>

On Monday 24 April 2006 16:59, Martin Schwidefsky wrote:

> Ok, sounds reasonable. Do we need to drop the _hva name component? If we
> do that then something like page_hva_unmap_all will be named
> page_unmap_all which might be a bit confusing as well.

I would drop it because it seems like a very s390 specific term.

-Andi
P.S.: I read somewhere that M$ calls such Hypervisor
hints enlightenments. Seems like a cool term to me. Maybe it can be used.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
