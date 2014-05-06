Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 363E96B0036
	for <linux-mm@kvack.org>; Tue,  6 May 2014 12:30:10 -0400 (EDT)
Received: by mail-wi0-f173.google.com with SMTP id bs8so7630361wib.0
        for <linux-mm@kvack.org>; Tue, 06 May 2014 09:30:09 -0700 (PDT)
Received: from mail.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id p10si5858271wjq.130.2014.05.06.09.30.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 May 2014 09:30:08 -0700 (PDT)
Message-ID: <53690D97.50401@zytor.com>
Date: Tue, 06 May 2014 09:28:07 -0700
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [patch 2/2] mm: pgtable -- Require X86_64 for soft-dirty tracker
References: <20140425081030.185969086@openvz.org> <20140425082042.848656782@openvz.org>
In-Reply-To: <20140425082042.848656782@openvz.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@openvz.org>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, torvalds@linux-foundation.org, mgorman@suse.de, mingo@kernel.org, steven@uplinklabs.net, riel@redhat.com, david.vrabel@citrix.com, akpm@linux-foundation.org, peterz@infradead.org, xemul@parallels.com

On 04/25/2014 01:10 AM, Cyrill Gorcunov wrote:
> Tracking dirty status on 2 level pages requires very ugly macros
> and taking into account how old the machines who can operate
> without PAE mode only are, lets drop soft dirty tracker from
> them for code simplicity (note I can't drop all the macros
> from 2 level pages by now since _PAGE_BIT_PROTNONE and
> _PAGE_BIT_FILE are still used even without tracker).
> 
> Linus proposed to completely rip off softdirty support on
> x86-32 (even with PAE) and since for CRIU we're not planning
> to support native x86-32 mode, lets do that.
> 
> (Softdirty tracker is relatively new feature which mostly used
>  by CRIU so I don't expect if such API change would cause problems
>  on userspace).

I have to wonder which one is more likely to actually matter on whatever
legacy 32-bit are going to remain.  This pretty much comes down to what
kind of advanced features are going to matter in deep embedded
applications in the future: checkpoint/restart or NUMA.  My guess is
that it is actually checkpoint/restart...

How much does it actually simplify to leave this feature in for PAE?  I
could care less about non-PAE... NX has pretty much killed that off cold.

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
