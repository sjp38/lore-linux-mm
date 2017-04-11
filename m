Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id F1EC56B03C2
	for <linux-mm@kvack.org>; Tue, 11 Apr 2017 15:00:46 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id c130so7326404ioe.19
        for <linux-mm@kvack.org>; Tue, 11 Apr 2017 12:00:46 -0700 (PDT)
Received: from resqmta-ch2-09v.sys.comcast.net (resqmta-ch2-09v.sys.comcast.net. [69.252.207.41])
        by mx.google.com with ESMTPS id h9si18397302ioa.170.2017.04.11.12.00.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Apr 2017 12:00:46 -0700 (PDT)
Date: Tue, 11 Apr 2017 13:59:44 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH] mm: Add additional consistency check
In-Reply-To: <20170411185555.GE21171@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.20.1704111356460.6911@east.gentwo.org>
References: <20170404201334.GV15132@dhcp22.suse.cz> <CAGXu5jL1t2ZZkwnGH9SkFyrKDeCugSu9UUzvHf3o_MgraDFL1Q@mail.gmail.com> <20170411134618.GN6729@dhcp22.suse.cz> <CAGXu5j+EVCU1WrjpMmr0PYW2N_RzF0tLUgFumDR+k4035uqthA@mail.gmail.com> <20170411141956.GP6729@dhcp22.suse.cz>
 <alpine.DEB.2.20.1704111110130.24725@east.gentwo.org> <20170411164134.GA21171@dhcp22.suse.cz> <alpine.DEB.2.20.1704111254390.25069@east.gentwo.org> <20170411183035.GD21171@dhcp22.suse.cz> <alpine.DEB.2.20.1704111335540.6544@east.gentwo.org>
 <20170411185555.GE21171@dhcp22.suse.cz>
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, 11 Apr 2017, Michal Hocko wrote:

> I didn't say anything like that. Hence the proposed patch which still
> needs some more thinking and evaluation.

This patch does not even affect kfree(). Could you start another
discussion thread where you discuss your suggestions for the changes in
the allocators and how we could go about this?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
