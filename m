Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id 19EA16B0036
	for <linux-mm@kvack.org>; Tue, 20 May 2014 13:21:38 -0400 (EDT)
Received: by mail-la0-f41.google.com with SMTP id e16so668864lan.14
        for <linux-mm@kvack.org>; Tue, 20 May 2014 10:21:38 -0700 (PDT)
Received: from mail-lb0-x235.google.com (mail-lb0-x235.google.com [2a00:1450:4010:c04::235])
        by mx.google.com with ESMTPS id og9si9703479lbb.87.2014.05.20.10.21.37
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 20 May 2014 10:21:37 -0700 (PDT)
Received: by mail-lb0-f181.google.com with SMTP id q8so650333lbi.40
        for <linux-mm@kvack.org>; Tue, 20 May 2014 10:21:37 -0700 (PDT)
Date: Tue, 20 May 2014 21:21:34 +0400
From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 3/4] x86,mm: Improve _install_special_mapping and fix x86
 vdso naming
Message-ID: <20140520172134.GJ2185@moon>
References: <cover.1400538962.git.luto@amacapital.net>
 <276b39b6b645fb11e345457b503f17b83c2c6fd0.1400538962.git.luto@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <276b39b6b645fb11e345457b503f17b83c2c6fd0.1400538962.git.luto@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: x86@kernel.org, Andrew Morton <akpm@linux-foundation.org>, Sasha Levin <sasha.levin@oracle.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Pavel Emelyanov <xemul@parallels.com>, "H. Peter Anvin" <hpa@zytor.com>

On Mon, May 19, 2014 at 03:58:33PM -0700, Andy Lutomirski wrote:
> Using arch_vma_name to give special mappings a name is awkward.  x86
> currently implements it by comparing the start address of the vma to
> the expected address of the vdso.  This requires tracking the start
> address of special mappings and is probably buggy if a special vma
> is split or moved.
> 
> Improve _install_special_mapping to just name the vma directly.  Use
> it to give the x86 vvar area a name, which should make CRIU's life
> easier.
> 
> As a side effect, the vvar area will show up in core dumps.  This
> could be considered weird and is fixable.  Thoughts?
> 
> Cc: Cyrill Gorcunov <gorcunov@openvz.org>
> Cc: Pavel Emelyanov <xemul@parallels.com>
> Signed-off-by: Andy Lutomirski <luto@amacapital.net>

Hi Andy, thanks a lot for this! I must confess I don't yet know how
would we deal with compat tasks but this is 'must have' mark which
allow us to detect vvar area!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
