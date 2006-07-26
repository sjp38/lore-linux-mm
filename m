Date: Wed, 26 Jul 2006 19:59:31 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] vm/agp: remove private page protection map
Message-ID: <20060726235931.GA5687@redhat.com>
References: <Pine.LNX.4.64.0607181905140.26533@skynet.skynet.ie> <Pine.LNX.4.64.0607262135440.11629@blonde.wat.veritas.com> <Pine.LNX.4.64.0607270023120.23571@skynet.skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0607270023120.23571@skynet.skynet.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Airlie <airlied@linux.ie>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, Dave Jones <davej@codemonkey.org.uk>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 27, 2006 at 12:24:27AM +0100, Dave Airlie wrote:
 > >
 > >I'm happy with the intent of your vm_get_page_prot() patch (and would
 > >like to extend it to other places after, minimizing references to the
 > >protection_map[]).  But there's a few aspects which distress me - the
 > >u8 type nowhere else in mm, the requirement that caller mask the arg,
 > >agp_convert_mmap_flags still using its own conversion from PROT_ to VM_
 > >while there's an inline in mm.h (though why someone thought to optimize
 > >and so obscure that version puzzles me!).  Would you be happy to insert
 > >your Sign-off in the replacement below?
 > 
 > No worries, I think davej can drop my one from his tree as well and take 
 > this..

Done, and pushed out to agpgart.git

Thanks,

		Dave

-- 
http://www.codemonkey.org.uk

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
