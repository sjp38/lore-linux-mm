Date: Tue, 18 Jul 2006 14:23:28 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] vm/agp: remove private page protection map
Message-ID: <20060718182328.GA7567@redhat.com>
References: <Pine.LNX.4.64.0607181905140.26533@skynet.skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0607181905140.26533@skynet.skynet.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Airlie <airlied@linux.ie>
Cc: linux-kernel@vger.kernel.org, davej@codemonkey.org.uk, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 18, 2006 at 07:08:12PM +0100, Dave Airlie wrote:
 > 
 > AGP keeps its own copy of the protection_map, upcoming DRM changes
 > will also require access to this map from modules.

Nice. I've always disliked having this knowledge in the agp driver.
I'll queue this up.

		Dave

-- 
http://www.codemonkey.org.uk

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
