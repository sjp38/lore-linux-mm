Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 723736B03A0
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 09:31:26 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id x86so136294075ioe.5
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 06:31:26 -0700 (PDT)
Received: from resqmta-ch2-11v.sys.comcast.net (resqmta-ch2-11v.sys.comcast.net. [2001:558:fe21:29:69:252:207:43])
        by mx.google.com with ESMTPS id e42si15308889ioj.166.2017.04.18.06.31.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Apr 2017 06:31:25 -0700 (PDT)
Date: Tue, 18 Apr 2017 08:31:24 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: Add additional consistency check
In-Reply-To: <20170418064124.GA22360@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1704180829360.13656@east.gentwo.org>
References: <20170411141956.GP6729@dhcp22.suse.cz> <alpine.DEB.2.20.1704111110130.24725@east.gentwo.org> <20170411164134.GA21171@dhcp22.suse.cz> <alpine.DEB.2.20.1704111254390.25069@east.gentwo.org> <20170411183035.GD21171@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704111335540.6544@east.gentwo.org> <20170411185555.GE21171@dhcp22.suse.cz> <alpine.DEB.2.20.1704111356460.6911@east.gentwo.org> <20170411193948.GA29154@dhcp22.suse.cz> <alpine.DEB.2.20.1704171021450.28407@east.gentwo.org>
 <20170418064124.GA22360@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 18 Apr 2017, Michal Hocko wrote:

> > The patch does not do that. See my review. Invalid points to kfree are
> > already caught with a bug on. See kfree in mm/slub.c
>
> Are you even reading those emails? First of all we are talking about
> slab here. Secondly I've already pointed out that the BUG_ON(!PageSlab)
> in kmem_freepages is already too late because we do operate on a
> potential garbage from invalid page...

Again this is confusing because you are discussing something that was not
covered by the patch submitted. Please start another discussion thread
on kfree() separately from the discussion of the patch here.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
